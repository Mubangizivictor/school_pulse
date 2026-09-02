// Single source of truth for the School Pulse public marketing site.
//
// Every fact here is verified against the codebase (lib/core/constants/
// support_contact.dart, welcome_screen.dart, about_school_pulse_screen.dart,
// public_functions/portal_domains.js). No customer counts, ratings, pricing,
// or compliance claims are asserted anywhere — those are deliberately absent
// because the codebase does not substantiate them.

// Canonical public host. Per the operator's instruction the canonical host is
// the bare apex (no www); www.schoolpulseapp.com 301-redirects here at the
// Firebase Hosting domain level. All canonical tags, sitemap URLs, and OG
// URLs use this host.
const CANONICAL_HOST = 'https://schoolpulseapp.com';

const CONTACT = {
  company: 'School Pulse',
  tagline: 'Educate • Empower • Excel',
  email: 'mubangizivic@gmail.com',
  phoneDisplay: '+256 793 128 137',
  phoneTel: '+256793128137',
  whatsapp: '256793128137', // wa.me format, no '+'
  country: 'Uganda',
};

const OG_IMAGE = `${CANONICAL_HOST}/assets-marketing/og-cover.svg`;

// The one-line positioning statement, taken verbatim from
// about_school_pulse_screen.dart.
const POSITIONING =
  'School Pulse is an all-in-one school management solution that empowers ' +
  'schools to manage academic, administrative and communication processes ' +
  'efficiently.';

// Marketing pages. `path` is the canonical path on the www host.
// `changefreq`/`priority` are advisory only. `lastmod` is filled at build
// time from git history of the generator + config (best available signal
// for hand-authored pages).
const PAGES = [
  // "/" is the marketing homepage (same content as the primary landing
  // page below, at the canonical root path). The Flutter app now boots
  // at /app/ instead — see web/index.html's --base-href=/app/ build flag
  // and firebase.json's rewrite of unmatched paths to /app/index.html.
  {
    path: '/',
    slug: 'home',
    title: 'School Pulse — School Management Software for Uganda',
    description:
      'School management software built for Ugandan schools. Manage students, ' +
      'staff, attendance, fees and academics, with MTN Mobile Money fee ' +
      'records and parent access on any phone.',
    h1: 'School management software built for Ugandan schools',
    priority: '1.0',
    changefreq: 'monthly',
  },
  {
    path: '/school-management-software-uganda',
    slug: 'school-management-software-uganda',
    title: 'School Management Software in Uganda — School Pulse',
    description:
      'School management software built for Ugandan schools. Manage students, ' +
      'staff, attendance, fees and academics, with MTN Mobile Money fee ' +
      'records and parent access on any phone.',
    h1: 'School management software built for Ugandan schools',
    priority: '0.9',
    changefreq: 'monthly',
  },
  {
    path: '/parent-portal',
    slug: 'parent-portal',
    title: 'Parent Portal — Follow Your Child’s School Life | School Pulse',
    description:
      'The School Pulse Parent Portal lets parents check attendance, academic ' +
      'progress, fee balances and school messages for their own child, from ' +
      'any browser or phone.',
    h1: 'A parent portal parents actually use',
    priority: '0.8',
    changefreq: 'monthly',
  },
  {
    path: '/student-information-and-enrolment',
    slug: 'student-information-and-enrolment',
    title: 'Student Information & Enrolment — School Pulse',
    description:
      'Keep one accurate record per learner: enrolment, class and stream ' +
      'placement, guardian contacts and student credentials, all in the ' +
      'School Pulse student information system.',
    h1: 'One reliable record for every learner',
    priority: '0.8',
    changefreq: 'monthly',
  },
  {
    path: '/fees-and-payments',
    slug: 'fees-and-payments',
    title: 'School Fees & Payments — School Pulse',
    description:
      'Track fee billing and payment records in School Pulse, with MTN Mobile ' +
      'Money transaction references and clear balances for parents and the ' +
      'bursar’s office.',
    h1: 'Fees and payments, clearly tracked',
    priority: '0.8',
    changefreq: 'monthly',
  },
  {
    path: '/attendance',
    slug: 'attendance',
    title: 'School Attendance Tracking — School Pulse',
    description:
      'Record daily and lesson attendance in School Pulse, review patterns by ' +
      'class or learner, and keep parents informed through the parent portal.',
    h1: 'Attendance that takes seconds to record',
    priority: '0.7',
    changefreq: 'monthly',
  },
  {
    path: '/academics-and-report-cards',
    slug: 'academics-and-report-cards',
    title: 'Academics & Report Cards — School Pulse',
    description:
      'Manage subjects, assessments and report cards in School Pulse, with a ' +
      'structured approval and release workflow before results reach parents.',
    h1: 'From marks entry to released report cards',
    priority: '0.7',
    changefreq: 'monthly',
  },
  {
    path: '/school-communication',
    slug: 'school-communication',
    title: 'School Communication & Messaging — School Pulse',
    description:
      'Send announcements and messages to staff and parents from School Pulse, ' +
      'and keep a record of what was communicated and when.',
    h1: 'Reach parents and staff without the group-chat chaos',
    priority: '0.7',
    changefreq: 'monthly',
  },
  {
    path: '/transport-and-boarding',
    slug: 'transport-and-boarding',
    title: 'Transport & Boarding Management — School Pulse',
    description:
      'Organise transport and boarding information in School Pulse alongside ' +
      'the rest of each learner’s record, so the whole school works from one ' +
      'system.',
    h1: 'Transport and boarding, in the same system as everything else',
    priority: '0.6',
    changefreq: 'monthly',
  },
  {
    path: '/health-and-welfare',
    slug: 'health-and-welfare',
    title: 'School Health & Welfare Records — School Pulse',
    description:
      'The School Pulse clinic module records learner clinic visits, ' +
      'medicine stock and welfare notes, with role-based access so sensitive ' +
      'health information stays with the people who need it.',
    h1: 'A school clinic that keeps proper records',
    priority: '0.6',
    changefreq: 'monthly',
  },
  {
    path: '/school-websites',
    slug: 'school-websites',
    title: 'School Websites & Portal Subdomains — School Pulse',
    description:
      'Every School Pulse school gets its own branded portal at ' +
      'your-school.schoolpulseapp.com, with the option to connect a custom ' +
      'domain.',
    h1: 'Your school’s own branded portal',
    priority: '0.6',
    changefreq: 'monthly',
  },
  {
    path: '/request-demo',
    slug: 'request-demo',
    title: 'Request a School Pulse Demo',
    description:
      'See School Pulse with your own school in mind. Request a walkthrough ' +
      'by email or WhatsApp and we’ll show you how it fits your school.',
    h1: 'Request a demo',
    priority: '0.9',
    changefreq: 'monthly',
  },
  {
    path: '/about',
    slug: 'about',
    title: 'About School Pulse',
    description:
      'School Pulse is an all-in-one school management platform used by ' +
      'schools, parents and staff. Learn what we build and why.',
    h1: 'About School Pulse',
    priority: '0.5',
    changefreq: 'yearly',
  },
  {
    path: '/contact',
    slug: 'contact',
    title: 'Contact School Pulse',
    description:
      'Get in touch with School Pulse by email or WhatsApp. We’re based in ' +
      'Uganda and work with schools across the country.',
    h1: 'Contact us',
    priority: '0.6',
    changefreq: 'yearly',
  },
  {
    path: '/privacy-policy',
    slug: 'privacy-policy',
    title: 'Privacy Policy — School Pulse',
    description:
      'How School Pulse collects, uses and protects information in the school ' +
      'management platform. This policy is a draft pending formal legal ' +
      'review.',
    priority: '0.3',
    changefreq: 'yearly',
    noindexHint: false,
  },
  {
    path: '/terms-of-service',
    slug: 'terms-of-service',
    title: 'Terms of Service — School Pulse',
    description:
      'The terms under which schools and users may use the School Pulse ' +
      'platform. This document is a draft pending formal legal review.',
    priority: '0.3',
    changefreq: 'yearly',
  },
];

// The whole Flutter SPA now lives under /app/ (see web/index.html's
// --base-href=/app/ build flag and firebase.json's rewrite of unmatched
// paths to /app/index.html) — one Disallow line covers every app/auth/
// tenant route. /verify* stay separate: they're Cloud Function rewrites,
// not app routes, but still carry no marketing/SEO value.
const APP_DISALLOW = [
  '/app/',
  '/verify',
  '/verify-student',
  '/verify-report',
];

module.exports = {
  CANONICAL_HOST,
  CONTACT,
  OG_IMAGE,
  POSITIONING,
  PAGES,
  APP_DISALLOW,
};
