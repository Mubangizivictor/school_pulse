// Injects the shared, compact site footer into #site-footer on every page.
(function () {
  var year = new Date().getFullYear();
  var html = `
  <footer class="site-footer">
    <div class="container footer-inner">
      <div class="footer-top-row">
        <div class="footer-brand">
          <a href="index.html" class="brand" style="color:#fff;">
            <span class="brand-mark"><img src="assets/logos/icon-dark.png" alt="" width="28" height="28" style="height:100%;width:auto;display:block;"></span>
            School Pulse
          </a>
          <p>School management built for Ugandan schools.</p>
        </div>

        <div class="footer-links-desktop">
          <div class="footer-col">
            <h4>Product</h4>
            <a href="platform.html">Platform</a>
            <a href="pricing.html">Pricing</a>
          </div>
          <div class="footer-col">
            <h4>Company</h4>
            <a href="contact.html">Contact</a>
            <a href="resources.html">Resources</a>
          </div>
        </div>

        <div class="footer-links-mobile">
          <div class="footer-accordion">
            <button type="button" class="footer-accordion-trigger" aria-expanded="false" aria-controls="footer-acc-product">
              Product
              <span class="footer-accordion-icon" aria-hidden="true">${window.ICONS ? window.ICONS['chevron-down'] : ''}</span>
            </button>
            <div id="footer-acc-product" class="footer-accordion-panel">
              <a href="platform.html">Platform</a>
              <a href="pricing.html">Pricing</a>
            </div>
          </div>
          <div class="footer-accordion">
            <button type="button" class="footer-accordion-trigger" aria-expanded="false" aria-controls="footer-acc-company">
              Company
              <span class="footer-accordion-icon" aria-hidden="true">${window.ICONS ? window.ICONS['chevron-down'] : ''}</span>
            </button>
            <div id="footer-acc-company" class="footer-accordion-panel">
              <a href="contact.html">Contact</a>
              <a href="resources.html">Resources</a>
            </div>
          </div>
        </div>

        <div class="footer-cta">
          <a href="register-school.html" class="footer-cta-btn">Register your school <span aria-hidden="true">&rarr;</span></a>
        </div>
      </div>

      <div class="footer-bottom">
        <span>&copy; ${year} School Pulse</span>
        <div class="footer-legal">
          <a href="privacy.html">Privacy</a>
          <span aria-hidden="true">|</span>
          <a href="terms.html">Terms</a>
        </div>
        <div class="footer-social">
          <a href="https://facebook.com" target="_blank" rel="noopener" aria-label="School Pulse on Facebook"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M13.5 21v-7.7h2.6l.4-3h-3v-1.9c0-.87.24-1.46 1.5-1.46H16.6V4.14C16.34 4.1 15.46 4 14.44 4 12.3 4 10.85 5.3 10.85 7.7v2.6H8.25v3h2.6V21h2.65Z"/></svg></a>
          <a href="https://twitter.com" target="_blank" rel="noopener" aria-label="School Pulse on Twitter"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M22 5.9c-.7.3-1.5.5-2.3.6.8-.5 1.4-1.3 1.7-2.3-.8.5-1.7.8-2.6 1a4.1 4.1 0 0 0-7 3.7A11.6 11.6 0 0 1 3.4 4.6a4.1 4.1 0 0 0 1.3 5.5c-.6 0-1.3-.2-1.8-.5v.1c0 2 1.4 3.6 3.3 4a4.1 4.1 0 0 1-1.9.1c.5 1.6 2 2.8 3.8 2.9A8.3 8.3 0 0 1 2 18.6a11.6 11.6 0 0 0 6.3 1.8c7.5 0 11.6-6.2 11.6-11.6v-.5c.8-.6 1.5-1.3 2.1-2.1Z"/></svg></a>
          <a href="https://linkedin.com" target="_blank" rel="noopener" aria-label="School Pulse on LinkedIn"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M6.94 5a2 2 0 1 1-4 0 2 2 0 0 1 4 0ZM3.2 8.75h3.5V21H3.2V8.75Zm6.2 0h3.36v1.68h.05c.47-.9 1.6-1.85 3.3-1.85 3.53 0 4.18 2.32 4.18 5.35V21h-3.5v-6.4c0-1.53-.03-3.5-2.13-3.5-2.14 0-2.46 1.67-2.46 3.39V21H9.4V8.75Z"/></svg></a>
        </div>
      </div>
    </div>
  </footer>`;
  var mount = document.getElementById('site-footer');
  if (mount) mount.outerHTML = html;

  document.querySelectorAll('.footer-accordion-trigger').forEach(function (trigger) {
    trigger.addEventListener('click', function () {
      var panel = document.getElementById(trigger.getAttribute('aria-controls'));
      var expanded = trigger.getAttribute('aria-expanded') === 'true';
      trigger.setAttribute('aria-expanded', String(!expanded));
      panel.style.maxHeight = expanded ? '0px' : panel.scrollHeight + 'px';
    });
  });
})();
