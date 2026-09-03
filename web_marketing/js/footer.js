// Injects the shared site footer into #site-footer on every page.
(function () {
  var year = new Date().getFullYear();
  var html = `
  <footer class="site-footer">
    <div class="container">
      <div class="footer-top">
        <div class="footer-brand">
          <a href="index.html" class="brand" style="color:#fff;">
            <span class="brand-mark">SP</span>
            School Pulse
          </a>
          <p>The multi-tenant school-management platform built for Ugandan schools &mdash; attendance, fees, academics and parent communication, all in one place.</p>
        </div>
        <div class="footer-col">
          <h4>Platform</h4>
          <a href="platform.html">Platform overview</a>
          <a href="students-and-enrolment.html">Students &amp; Enrolment</a>
          <a href="attendance.html">Attendance</a>
          <a href="fees-and-payments.html">Fees &amp; Payments</a>
          <a href="academics-and-report-cards.html">Academics &amp; Report Cards</a>
          <a href="parent-portal.html">Parent Portal</a>
        </div>
        <div class="footer-col">
          <h4>For Schools</h4>
          <a href="for-schools.html">Solutions</a>
          <a href="pricing.html">Pricing</a>
          <a href="school-websites.html">School Websites</a>
          <a href="request-demo.html">Request a demo</a>
          <a href="register-school.html">Register your school</a>
        </div>
        <div class="footer-col">
          <h4>Company</h4>
          <a href="resources.html">Resources</a>
          <a href="contact.html">Contact</a>
          <a href="login.html">Sign in</a>
        </div>
      </div>
      <div class="footer-bottom">
        <span>&copy; ${year} School Pulse. All rights reserved.</span>
        <div style="display:flex; gap:20px;">
          <a href="privacy.html">Privacy Policy</a>
          <a href="terms.html">Terms of Service</a>
        </div>
      </div>
    </div>
  </footer>`;
  var mount = document.getElementById('site-footer');
  if (mount) mount.outerHTML = html;
})();
