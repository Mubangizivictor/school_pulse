// Injects the shared site header/nav into #site-nav on every page.
(function () {
  var html = `
  <header class="site-header">
    <div class="nav-wrap">
      <a href="index.html" class="brand">
        <span class="brand-mark">SP</span>
        School Pulse
      </a>

      <nav class="nav-main" aria-label="Primary">
        <div class="nav-item">
          <button class="nav-link" data-dd="platform" aria-haspopup="true" aria-expanded="false">
            Platform
            <svg class="nav-caret" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>
          </button>
          <div class="dropdown" id="dd-platform" role="menu">
            <a href="platform.html" role="menuitem">Platform overview<span>All modules working together</span></a>
            <a href="students-and-enrolment.html" role="menuitem">Students &amp; Enrolment<span>Admissions to enrolled learners</span></a>
            <a href="attendance.html" role="menuitem">Attendance<span>Daily check-in, instantly</span></a>
            <a href="fees-and-payments.html" role="menuitem">Fees &amp; Payments<span>Collections made simple</span></a>
            <a href="academics-and-report-cards.html" role="menuitem">Academics &amp; Report Cards<span>Marks to shareable reports</span></a>
            <a href="parent-portal.html" role="menuitem">Parent Portal<span>Keep families in the loop</span></a>
          </div>
        </div>

        <div class="nav-item">
          <button class="nav-link" data-dd="schools" aria-haspopup="true" aria-expanded="false">
            For Schools
            <svg class="nav-caret" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>
          </button>
          <div class="dropdown" id="dd-schools" role="menu">
            <a href="for-schools.html" role="menuitem">Solutions overview<span>Built for every school type</span></a>
            <a href="for-schools.html#nursery" role="menuitem">Nursery schools<span>Simple, gentle, visual</span></a>
            <a href="for-schools.html#primary" role="menuitem">Primary schools<span>Structured &amp; parent-friendly</span></a>
            <a href="for-schools.html#secondary" role="menuitem">Secondary schools<span>Subjects, streams, exams</span></a>
            <a href="for-schools.html#international" role="menuitem">International schools<span>Multi-curriculum ready</span></a>
          </div>
        </div>

        <a href="pricing.html" class="nav-link">Pricing</a>
        <a href="school-websites.html" class="nav-link">School Websites</a>

        <div class="nav-item">
          <button class="nav-link" data-dd="resources" aria-haspopup="true" aria-expanded="false">
            Resources
            <svg class="nav-caret" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>
          </button>
          <div class="dropdown" id="dd-resources" role="menu">
            <a href="resources.html" role="menuitem">Resource centre<span>Guides &amp; articles</span></a>
            <a href="contact.html" role="menuitem">Contact us<span>Talk to our team</span></a>
            <a href="request-demo.html" role="menuitem">Request a demo<span>See it live</span></a>
          </div>
        </div>
      </nav>

      <div class="nav-actions">
        <a href="login.html" class="signin-link">Sign in</a>
        <a href="register-school.html" class="btn btn-primary">Register your school</a>
        <button class="hamburger" id="hamburgerBtn" aria-label="Open menu" aria-expanded="false">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 7h16M4 12h16M4 17h16"/></svg>
        </button>
      </div>
    </div>

    <div class="mobile-panel" id="mobilePanel">
      <details class="m-group">
        <summary>Platform
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>
        </summary>
        <div class="m-sub">
          <a href="platform.html">Platform overview</a>
          <a href="students-and-enrolment.html">Students &amp; Enrolment</a>
          <a href="attendance.html">Attendance</a>
          <a href="fees-and-payments.html">Fees &amp; Payments</a>
          <a href="academics-and-report-cards.html">Academics &amp; Report Cards</a>
          <a href="parent-portal.html">Parent Portal</a>
        </div>
      </details>
      <details class="m-group">
        <summary>For Schools
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>
        </summary>
        <div class="m-sub">
          <a href="for-schools.html">Solutions overview</a>
          <a href="for-schools.html#nursery">Nursery schools</a>
          <a href="for-schools.html#primary">Primary schools</a>
          <a href="for-schools.html#secondary">Secondary schools</a>
          <a href="for-schools.html#international">International schools</a>
        </div>
      </details>
      <a href="pricing.html" class="m-link">Pricing</a>
      <a href="school-websites.html" class="m-link">School Websites</a>
      <details class="m-group">
        <summary>Resources
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>
        </summary>
        <div class="m-sub">
          <a href="resources.html">Resource centre</a>
          <a href="contact.html">Contact us</a>
          <a href="request-demo.html">Request a demo</a>
        </div>
      </details>
      <div class="m-actions">
        <a href="login.html" class="btn btn-outline btn-block">Sign in</a>
        <a href="register-school.html" class="btn btn-primary btn-block">Register your school</a>
      </div>
    </div>
  </header>`;

  var mount = document.getElementById('site-nav');
  if (mount) mount.outerHTML = html;

  function closeAllDropdowns() {
    document.querySelectorAll('.dropdown.open').forEach(function (d) { d.classList.remove('open'); });
    document.querySelectorAll('.nav-link[aria-expanded="true"]').forEach(function (b) { b.setAttribute('aria-expanded', 'false'); });
  }

  document.querySelectorAll('.nav-link[data-dd]').forEach(function (btn) {
    btn.addEventListener('click', function (e) {
      e.stopPropagation();
      var id = 'dd-' + btn.getAttribute('data-dd');
      var dd = document.getElementById(id);
      var isOpen = dd.classList.contains('open');
      closeAllDropdowns();
      if (!isOpen) {
        dd.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
      }
    });
  });

  document.addEventListener('click', function (e) {
    if (!e.target.closest('.nav-item')) closeAllDropdowns();
  });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeAllDropdowns();
  });

  var hamburgerBtn = document.getElementById('hamburgerBtn');
  var mobilePanel = document.getElementById('mobilePanel');
  if (hamburgerBtn && mobilePanel) {
    hamburgerBtn.addEventListener('click', function () {
      var open = mobilePanel.classList.toggle('open');
      hamburgerBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
  }

  // Highlight current page link
  var path = location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-link, .m-link').forEach(function (a) {
    if (a.getAttribute('href') === path) a.style.color = 'var(--color-primary)';
  });
})();
