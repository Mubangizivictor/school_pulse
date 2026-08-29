// Visible marketing copy for each public page, keyed by slug.
//
// Copy is written for School Pulse specifically and stays within what the
// product actually does (verified against the Flutter modules and Cloud
// Functions). It makes no claims about number of schools, ratings, uptime,
// certifications, or regulatory compliance, and quotes no customers.
//
// Each entry returns the inner HTML of <main>. The shared template supplies
// <header>, <footer>, skip link, and all <head> metadata.

const { CONTACT } = require('./site.config');

const WA = `https://wa.me/${CONTACT.whatsapp}`;
const MAILTO = `mailto:${CONTACT.email}?subject=${encodeURIComponent(
  'School Pulse demo request',
)}`;

const ctaBlock = (heading = 'See School Pulse with your school in mind') => `
  <section class="cta" aria-labelledby="cta-heading">
    <h2 id="cta-heading">${heading}</h2>
    <p>Tell us about your school and we’ll walk you through how School Pulse fits.</p>
    <p class="cta-actions">
      <a class="btn btn-primary" href="/request-demo">Request a demo</a>
      <a class="btn btn-ghost" href="${WA}" rel="nofollow noopener" target="_blank">Message us on WhatsApp</a>
    </p>
  </section>`;

const featureGrid = () => `
  <section class="features" aria-labelledby="features-heading">
    <h2 id="features-heading">What School Pulse covers</h2>
    <ul class="grid">
      <li><h3><a href="/student-information-and-enrolment">Students &amp; enrolment</a></h3><p>One record per learner — enrolment, class and stream placement, guardian contacts and student credentials.</p></li>
      <li><h3><a href="/attendance">Attendance</a></h3><p>Daily and lesson attendance, with patterns visible by class or learner.</p></li>
      <li><h3><a href="/fees-and-payments">Fees &amp; payments</a></h3><p>Fee billing and payment records, with MTN Mobile Money transaction references.</p></li>
      <li><h3><a href="/academics-and-report-cards">Academics &amp; report cards</a></h3><p>Subjects, assessments and a report-card approval and release workflow.</p></li>
      <li><h3><a href="/school-communication">Communication</a></h3><p>Announcements and messages to staff and parents, with a record of what was sent.</p></li>
      <li><h3><a href="/parent-portal">Parent portal</a></h3><p>Parents follow their own child’s attendance, progress and fee balance.</p></li>
      <li><h3><a href="/transport-and-boarding">Transport &amp; boarding</a></h3><p>Transport and boarding information kept alongside the rest of the record.</p></li>
      <li><h3><a href="/health-and-welfare">Health &amp; welfare</a></h3><p>Clinic visits, medicine stock and welfare notes with role-based access.</p></li>
      <li><h3><a href="/school-websites">School websites</a></h3><p>A branded portal at your-school.schoolpulse.ug, with optional custom domain.</p></li>
    </ul>
  </section>`;

const CONTENT = {
  // Primary indexable landing page. "/" is the Flutter app, so this page
  // carries the strongest overview copy plus the site-wide JSON-LD entity
  // graph (wired in generate.js).
  'school-management-software-uganda': () => `
  <section class="hero" aria-labelledby="page-h1">
    <p class="eyebrow">${CONTACT.tagline}</p>
    <h1 id="page-h1">School management software built for Ugandan schools</h1>
    <p class="lede">${require('./site.config').POSITIONING}
      School Pulse is made for how schools in ${CONTACT.country} actually
      operate: fees paid by MTN Mobile Money, parents reachable on a basic
      phone, and staff who need the system to work without training days.</p>
    <p class="cta-actions">
      <a class="btn btn-primary" href="/request-demo">Request a demo</a>
      <a class="btn btn-ghost" href="/parent-portal">See the parent portal</a>
    </p>
  </section>
  <section aria-labelledby="ug-heading">
    <h2 id="ug-heading">What that means in practice</h2>
    <ul class="checks">
      <li><strong>Mobile Money fee records.</strong> Fee payments carry MTN Mobile Money transaction references, so the bursar’s office and parents see the same balance.</li>
      <li><strong>Works on any phone.</strong> The parent portal opens in a browser — no app install required.</li>
      <li><strong>Your own portal address.</strong> Each school runs at your-school.schoolpulse.ug, with the option to connect a custom domain.</li>
      <li><strong>Term-based structure.</strong> Classes, streams, subjects and report cards follow the Ugandan term system.</li>
    </ul>
  </section>
  ${featureGrid()}
  <section aria-labelledby="portals-heading">
    <h2 id="portals-heading">Built around three ways in</h2>
    <ul class="grid grid-3">
      <li><h3>Staff Gateway</h3><p>School operations and management for administrators, bursars, teachers and clinic staff.</p></li>
      <li><h3>Parent Portal</h3><p>Each parent sees only their own child’s information.</p></li>
      <li><h3>Student Hub</h3><p>Learners access their own timetable, results and school updates.</p></li>
    </ul>
  </section>
  ${ctaBlock()}`,

  'parent-portal': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">A parent portal parents actually use</h1>
    <p class="lede">The School Pulse Parent Portal gives each parent a clear view of
      their own child — nothing more, nothing less. It opens in any browser.</p>
  </section>
  <section aria-labelledby="pp-heading">
    <h2 id="pp-heading">What a parent can see</h2>
    <ul class="checks">
      <li>Attendance, including when a child was marked absent.</li>
      <li>Academic progress and released report cards.</li>
      <li>Fee balance and payment history for their child.</li>
      <li>Messages and announcements from the school.</li>
    </ul>
    <p>Access is scoped to the parent’s linked child only. Parents never see other
      learners’ records.</p>
  </section>
  ${ctaBlock('Show your parents a portal they’ll open')}`,

  'student-information-and-enrolment': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">One reliable record for every learner</h1>
    <p class="lede">School Pulse keeps a single student record from enrolment onward, so
      the office, the class teacher and the bursar are never working from
      different lists.</p>
  </section>
  <section aria-labelledby="sis-heading">
    <h2 id="sis-heading">In each learner’s record</h2>
    <ul class="checks">
      <li>Enrolment details and status.</li>
      <li>Class and stream placement.</li>
      <li>Guardian and parent contact details.</li>
      <li>Student credentials for the Student Hub.</li>
    </ul>
  </section>
  ${ctaBlock()}`,

  'fees-and-payments': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Fees and payments, clearly tracked</h1>
    <p class="lede">School Pulse records what each learner has been billed and what has
      been paid, with MTN Mobile Money transaction references attached to
      payments.</p>
  </section>
  <section aria-labelledby="fees-heading">
    <h2 id="fees-heading">For the bursar’s office and for parents</h2>
    <ul class="checks">
      <li>Fee billing per learner and per term.</li>
      <li>Payment records with Mobile Money references.</li>
      <li>Balances visible to parents in the parent portal.</li>
      <li>A clearance workflow that can gate report-card release on fees where a school chooses to.</li>
    </ul>
    <p>School Pulse records payments; it does not set your fees or make financial
      decisions for your school.</p>
  </section>
  ${ctaBlock()}`,

  attendance: () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Attendance that takes seconds to record</h1>
    <p class="lede">Mark a class present or absent from a phone, review the pattern later,
      and let the parent portal carry the news to parents.</p>
  </section>
  <section aria-labelledby="att-heading">
    <h2 id="att-heading">How it works</h2>
    <ul class="checks">
      <li>Daily roll-call and lesson-level attendance.</li>
      <li>Absence patterns by class or by learner.</li>
      <li>Attendance visible to parents for their own child.</li>
    </ul>
  </section>
  ${ctaBlock()}`,

  'academics-and-report-cards': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">From marks entry to released report cards</h1>
    <p class="lede">School Pulse takes assessments through a structured approval and release
      workflow, so nothing reaches a parent before the school signs it off.</p>
  </section>
  <section aria-labelledby="ac-heading">
    <h2 id="ac-heading">The academic workflow</h2>
    <ul class="checks">
      <li>Subjects and assessments per class and stream.</li>
      <li>Marks entry by subject teachers.</li>
      <li>Report-card approval before release.</li>
      <li>Optional financial clearance check on release.</li>
    </ul>
  </section>
  ${ctaBlock()}`,

  'school-communication': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Reach parents and staff without the group-chat chaos</h1>
    <p class="lede">Send an announcement once, to the right people, and keep a record of
      what was said.</p>
  </section>
  <section aria-labelledby="comms-heading">
    <h2 id="comms-heading">What you can send</h2>
    <ul class="checks">
      <li>Announcements to staff and to parents.</li>
      <li>Messages tied to a school, so context isn’t lost.</li>
      <li>A history of what was communicated and when.</li>
    </ul>
  </section>
  ${ctaBlock()}`,

  'transport-and-boarding': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Transport and boarding, in the same system as everything else</h1>
    <p class="lede">Keep transport and boarding information next to the rest of each
      learner’s record instead of in a separate book.</p>
  </section>
  <section aria-labelledby="tb-heading">
    <h2 id="tb-heading">Kept with the record</h2>
    <ul class="checks">
      <li>Transport and boarding details per learner.</li>
      <li>One system for the office, the class teacher and the parent portal.</li>
    </ul>
  </section>
  ${ctaBlock()}`,

  'health-and-welfare': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">A school clinic that keeps proper records</h1>
    <p class="lede">The School Pulse clinic module records clinic visits, medicine stock
      and welfare notes, with role-based access so sensitive health
      information stays with the people who need it.</p>
  </section>
  <section aria-labelledby="hw-heading">
    <h2 id="hw-heading">In the clinic module</h2>
    <ul class="checks">
      <li>Clinic visits with concern, notes and follow-up.</li>
      <li>Medicine and supplies stock, including low-stock alerts.</li>
      <li>Role-based access — teachers and parents see only what a school configures.</li>
    </ul>
    <p>School Pulse records care that clinic staff provide; it does not offer
      medical advice or diagnosis.</p>
  </section>
  ${ctaBlock()}`,

  'school-websites': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Your school’s own branded portal</h1>
    <p class="lede">Every School Pulse school gets a portal at
      <span class="mono">your-school.schoolpulse.ug</span>, carrying your school’s
      name and colours. You can connect a custom domain when you’re ready.</p>
  </section>
  <section aria-labelledby="sw-heading">
    <h2 id="sw-heading">How the address works</h2>
    <ul class="checks">
      <li>A reserved subdomain on schoolpulse.ug for each school.</li>
      <li>School name, logo and colours applied to the portal.</li>
      <li>Optional custom domain, verified by CNAME.</li>
    </ul>
  </section>
  ${ctaBlock()}`,

  'request-demo': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Request a demo</h1>
    <p class="lede">Tell us your school’s name, roughly how many learners you have, and
      what you’re trying to fix. We’ll show you how School Pulse fits — no
      obligation.</p>
  </section>
  <section aria-labelledby="rd-heading" class="contact-methods">
    <h2 id="rd-heading">Two ways to reach us</h2>
    <ul class="grid grid-2">
      <li>
        <h3>WhatsApp</h3>
        <p><a class="btn btn-primary" href="${WA}" rel="nofollow noopener" target="_blank">Chat on WhatsApp</a></p>
        <p class="mono">${CONTACT.phoneDisplay}</p>
      </li>
      <li>
        <h3>Email</h3>
        <p><a class="btn btn-ghost" href="${MAILTO}">Email us</a></p>
        <p class="mono">${CONTACT.email}</p>
      </li>
    </ul>
    <p>We’re based in ${CONTACT.country} and work with schools across the country.</p>
  </section>`,

  about: () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">About School Pulse</h1>
    <p class="lede">${require('./site.config').POSITIONING}</p>
  </section>
  <section aria-labelledby="about-heading">
    <h2 id="about-heading">What we build</h2>
    <p>School Pulse brings the parts of running a school — enrolment, attendance,
      fees, academics, communication, transport, boarding and health — into one
      platform, used through a Staff Gateway, a Parent Portal and a Student Hub.</p>
    <p>We’re a small team based in ${CONTACT.country}, building for schools here first.</p>
  </section>
  ${ctaBlock()}`,

  contact: () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Contact us</h1>
    <p class="lede">Questions about School Pulse, or want a walkthrough? Reach us by
      WhatsApp or email.</p>
  </section>
  <section aria-labelledby="c-heading" class="contact-methods">
    <h2 id="c-heading">Get in touch</h2>
    <ul class="grid grid-2">
      <li><h3>WhatsApp</h3><p><a class="btn btn-primary" href="${WA}" rel="nofollow noopener" target="_blank">Chat on WhatsApp</a></p><p class="mono">${CONTACT.phoneDisplay}</p></li>
      <li><h3>Email</h3><p><a class="btn btn-ghost" href="mailto:${CONTACT.email}">${CONTACT.email}</a></p></li>
    </ul>
    <p>Based in ${CONTACT.country}.</p>
  </section>`,

  'privacy-policy': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Privacy Policy</h1>
    <p class="note">This is a draft Privacy Policy provided as a starting point and is
      subject to change. It has not yet undergone formal legal review.</p>
  </section>
  <section aria-labelledby="pr1"><h2 id="pr1">1. Introduction</h2>
    <p>School Pulse (“we”, “our”, “the platform”) provides school management
      software used by schools, parents and staff. This Privacy Policy explains
      what information we collect through the platform, how we use it, and the
      choices you have.</p></section>
  <section aria-labelledby="pr2"><h2 id="pr2">2. Information we process</h2>
    <p>On behalf of the schools that use School Pulse, we process school records,
      student records (including enrolment, attendance, academic performance and
      guardian contact details), staff records, and fee payment records with
      Mobile Money transaction references.</p></section>
  <section aria-labelledby="pr3"><h2 id="pr3">3. How information is used</h2>
    <p>Information is used to provide the platform’s features to the school that
      owns the data — recording attendance, producing report cards, tracking
      fees, and enabling communication between the school, staff and parents.</p></section>
  <section aria-labelledby="pr4"><h2 id="pr4">4. Access</h2>
    <p>Access is role-based. Parents see only their own linked child. Staff see
      only what their role in their school permits. Health information is
      restricted to authorised clinic and administrative staff.</p></section>
  <section aria-labelledby="pr5"><h2 id="pr5">5. Contact</h2>
    <p>Questions about this policy can be sent to
      <a href="mailto:${CONTACT.email}">${CONTACT.email}</a>.</p></section>`,

  'terms-of-service': () => `
  <section class="hero" aria-labelledby="page-h1">
    <h1 id="page-h1">Terms of Service</h1>
    <p class="note">This document is a draft provided as a starting point and is subject
      to change. It has not yet undergone formal legal review.</p>
  </section>
  <section aria-labelledby="t1"><h2 id="t1">1. Agreement</h2>
    <p>These terms govern use of the School Pulse platform by schools and their
      authorised users. By using the platform you agree to these terms.</p></section>
  <section aria-labelledby="t2"><h2 id="t2">2. School responsibility</h2>
    <p>Each school is responsible for the accuracy of the records it enters, for
      managing its users’ access, and for using the platform in line with
      applicable law.</p></section>
  <section aria-labelledby="t3"><h2 id="t3">3. Acceptable use</h2>
    <p>The platform may not be used to attempt unauthorised access to other
      schools’ data or to disrupt the service.</p></section>
  <section aria-labelledby="t4"><h2 id="t4">4. Availability</h2>
    <p>We work to keep the platform available but do not guarantee uninterrupted
      service. Planned maintenance will be communicated where practical.</p></section>
  <section aria-labelledby="t5"><h2 id="t5">5. Contact</h2>
    <p>Questions about these terms can be sent to
      <a href="mailto:${CONTACT.email}">${CONTACT.email}</a>.</p></section>`,
};

// Genuine, product-accurate FAQs for the home page FAQPage JSON-LD.
const HOME_FAQ = [
  {
    q: 'What is School Pulse?',
    a:
      'School Pulse is an all-in-one school management platform covering ' +
      'enrolment, attendance, fees, report cards, communication, transport, ' +
      'boarding and health, used through a Staff Gateway, Parent Portal and ' +
      'Student Hub.',
  },
  {
    q: 'Do parents need to install an app?',
    a:
      'No. The Parent Portal opens in any web browser on a phone or computer. ' +
      'Each parent sees only their own child’s information.',
  },
  {
    q: 'How are school fees handled?',
    a:
      'School Pulse records fee billing and payments, with MTN Mobile Money ' +
      'transaction references attached to payments. It records payments; it ' +
      'does not set your fees.',
  },
  {
    q: 'Does each school get its own web address?',
    a:
      'Yes. Each school runs at your-school.schoolpulse.ug with its own name ' +
      'and colours, and can connect a custom domain later.',
  },
  {
    q: 'How do I see a demo?',
    a:
      'Contact School Pulse by WhatsApp or email from the Request a demo page ' +
      'and we’ll arrange a walkthrough for your school.',
  },
];

module.exports = { CONTENT, HOME_FAQ };
