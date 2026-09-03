// Drives the 6-step /register-school wizard: step nav, validation,
// localStorage persistence, and the live term-price summary panel.
(function () {
  var STORAGE_KEY = 'sp_register_school_draft_v1';
  var TOTAL_STEPS = 6;

  function initWizard() {
    var wizardEl = document.getElementById('registerWizard');
    if (!wizardEl) return;

    var currentStep = 1;
    var fields = wizardEl.querySelectorAll('input, select, textarea');

    // ---- localStorage persistence ----
    function saveDraft() {
      var data = {};
      fields.forEach(function (f) {
        if (!f.name) return;
        if (f.type === 'radio') {
          if (f.checked) data[f.name] = f.value;
        } else {
          data[f.name] = f.value;
        }
      });
      data.__step = currentStep;
      try { localStorage.setItem(STORAGE_KEY, JSON.stringify(data)); } catch (e) {}
    }

    function loadDraft() {
      var raw;
      try { raw = localStorage.getItem(STORAGE_KEY); } catch (e) { return; }
      if (!raw) return;
      var data;
      try { data = JSON.parse(raw); } catch (e) { return; }
      fields.forEach(function (f) {
        if (!f.name || !(f.name in data)) return;
        if (f.type === 'radio') {
          f.checked = f.value === data[f.name];
        } else {
          f.value = data[f.name];
        }
      });
      if (data.__step) currentStep = Math.min(Math.max(data.__step, 1), TOTAL_STEPS);
    }

    fields.forEach(function (f) { f.addEventListener('input', saveDraft); f.addEventListener('change', saveDraft); });

    // ---- Step rendering ----
    var stepIndicators = document.querySelectorAll('.wizard-step');
    var panels = document.querySelectorAll('.wizard-panel');

    function renderStep() {
      panels.forEach(function (p) {
        p.classList.toggle('active', Number(p.getAttribute('data-step')) === currentStep);
      });
      stepIndicators.forEach(function (s) {
        var n = Number(s.getAttribute('data-step'));
        s.classList.toggle('active', n === currentStep);
        s.classList.toggle('done', n < currentStep);
      });
      if (currentStep === TOTAL_STEPS) renderReview();
      updatePriceSummary();
      window.scrollTo({ top: wizardEl.offsetTop - 90, behavior: 'smooth' });
    }

    function fieldsForStep(step) {
      var panel = wizardEl.querySelector('.wizard-panel[data-step="' + step + '"]');
      if (!panel) return [];
      return Array.prototype.slice.call(panel.querySelectorAll('[required]'));
    }

    function validateStep(step) {
      var required = fieldsForStep(step);
      var valid = true;
      required.forEach(function (input) {
        var fieldEl = input.closest('.form-field') || input.parentElement;
        var value = (input.value || '').trim();
        fieldEl.classList.remove('has-error');
        if (!value) {
          fieldEl.classList.add('has-error');
          valid = false;
        } else if (input.type === 'email' && !window.SPForms.EMAIL_RE.test(value)) {
          fieldEl.classList.add('has-error');
          valid = false;
        }
      });
      return valid;
    }

    document.querySelectorAll('[data-wizard-next]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        if (!validateStep(currentStep)) return;
        saveDraft();
        if (currentStep < TOTAL_STEPS) {
          currentStep++;
          renderStep();
        }
      });
    });
    document.querySelectorAll('[data-wizard-back]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        if (currentStep > 1) {
          currentStep--;
          renderStep();
        }
      });
    });

    // ---- Live price summary ----
    function updatePriceSummary() {
      var countInput = wizardEl.querySelector('[name="studentCount"]');
      var summaryCount = document.getElementById('summaryStudentCount');
      var summaryTier = document.getElementById('summaryTier');
      var summaryPrice = document.getElementById('summaryPrice');
      if (!countInput || !summaryPrice) return;
      var count = Number(countInput.value) || 0;
      if (count <= 0) {
        summaryCount.textContent = '—';
        summaryTier.textContent = '—';
        summaryPrice.textContent = 'Enter student count';
        return;
      }
      var tier = window.getTierForCount(count);
      summaryCount.textContent = count.toLocaleString('en-UG');
      summaryTier.textContent = tier.label;
      summaryPrice.textContent = tier.price === null ? 'Talk to us' : window.formatUGX(tier.price) + ' / term';
    }
    var studentCountInput = wizardEl.querySelector('[name="studentCount"]');
    if (studentCountInput) studentCountInput.addEventListener('input', updatePriceSummary);

    // ---- Review step ----
    function renderReview() {
      var reviewEl = document.getElementById('wizardReview');
      if (!reviewEl) return;
      var rows = [
        ['School name', 'schoolName'],
        ['School initials', 'schoolPrefix'],
        ['School type', 'schoolType'],
        ['Curriculum', 'curriculum'],
        ['School email', 'schoolEmail'],
        ['School phone', 'schoolPhone'],
        ['Website', 'schoolWebsite'],
        ['Administrator name', 'adminName'],
        ['Administrator email', 'adminEmail'],
        ['Administrator phone', 'adminPhone'],
        ['Administrator role', 'adminRole'],
        ['School year', 'schoolYear'],
        ['Current term', 'term'],
        ['Term start date', 'termStart'],
        ['Term end date', 'termEnd'],
        ['Student count', 'studentCount'],
        ['Region', 'region'],
        ['District', 'district'],
        ['Address', 'address'],
        ['Desired subdomain', 'subdomain']
      ];
      var html = '';
      rows.forEach(function (r) {
        var input = wizardEl.querySelector('[name="' + r[1] + '"]');
        var value = input ? input.value : '';
        if (!value) return;
        if (r[1] === 'subdomain') value = value + '.schoolpulseapp.com';
        html += '<div class="summary-row"><span class="k">' + r[0] + '</span><span class="v">' + escapeHtml(value) + '</span></div>';
      });
      reviewEl.innerHTML = html || '<p class="muted">No details entered yet.</p>';
    }

    function escapeHtml(str) {
      var div = document.createElement('div');
      div.textContent = str;
      return div.innerHTML;
    }

    // Real submit wiring (account creation, email verification, backend
    // POST to submitSchoolApplication) now lives in js/register-submit.js —
    // it owns the #wizardSubmit click handler entirely, since a fake local
    // "success" here would let a user believe they'd registered when they
    // hadn't. It also owns clearing STORAGE_KEY on real success.

    // Subdomain preview + real availability checking now lives in
    // js/subdomain-check.js (backed by the live checkPortalSlug callable).

    // Expose small internals register-submit.js needs (current step,
    // validation, draft clearing) without duplicating this closure's state.
    window.SPWizard = {
      getStorageKey: function () { return STORAGE_KEY; },
      validateStep: validateStep,
      goToStep: function (step) { currentStep = Math.min(Math.max(step, 1), TOTAL_STEPS); renderStep(); },
      getCurrentStep: function () { return currentStep; },
    };

    loadDraft();
    renderStep();
  }

  document.addEventListener('DOMContentLoaded', initWizard);
})();
