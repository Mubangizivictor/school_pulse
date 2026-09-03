// Page-specific wiring: contact form, request-demo form.
// Nav/footer inject themselves (nav.js/footer.js). Wizard/estimator/faq
// self-init via DOMContentLoaded in their own files.
(function () {
  document.addEventListener('DOMContentLoaded', function () {
    initContactForm();
    initDemoForm();
  });

  function initContactForm() {
    var form = document.getElementById('contactForm');
    if (!form) return;
    var success = document.getElementById('contactSuccess');

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var rules = [
        { input: form.querySelector('[name="name"]'), required: true },
        { input: form.querySelector('[name="schoolName"]'), required: true },
        { input: form.querySelector('[name="email"]'), required: true, isEmail: true },
        { input: form.querySelector('[name="subject"]'), required: true },
        { input: form.querySelector('[name="message"]'), required: true }
      ];
      if (window.SPForms.validateForm(rules)) {
        window.SPForms.swapToSuccess(form, success);
      }
    });
  }

  function initDemoForm() {
    var form = document.getElementById('demoForm');
    if (!form) return;
    var success = document.getElementById('demoSuccess');

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var rules = [
        { input: form.querySelector('[name="schoolName"]'), required: true },
        { input: form.querySelector('[name="schoolType"]'), required: true },
        { input: form.querySelector('[name="learnerCount"]'), required: true },
        { input: form.querySelector('[name="workEmail"]'), required: true, isEmail: true }
      ];
      if (window.SPForms.validateForm(rules)) {
        window.SPForms.swapToSuccess(form, success);
      }
    });
  }
})();
