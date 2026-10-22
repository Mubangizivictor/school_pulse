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
        } else if (f.type === 'checkbox') {
          data[f.name] = f.checked;
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
        } else if (f.type === 'checkbox') {
          f.checked = !!data[f.name];
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
        var isDone = n < currentStep;
        s.classList.toggle('active', n === currentStep);
        s.classList.toggle('done', isDone);
        var circle = s.querySelector('.wizard-circle');
        if (circle) {
          if (isDone && window.ICONS && window.ICONS.check) {
            circle.innerHTML = window.ICONS.check;
          } else {
            circle.textContent = String(n);
          }
        }
      });
      var stepCount = document.getElementById('wizardStepCount');
      if (stepCount) stepCount.textContent = 'Step ' + currentStep + ' of ' + TOTAL_STEPS;
      if (currentStep === TOTAL_STEPS) renderReview();
      updatePriceSummary();
      updateCalendarPreview();

      // Sidebar swap: the live term-price panel is replaced on the final
      // Review step by the subscription summary + "what happens next?" panel.
      var onReview = currentStep === TOTAL_STEPS;
      var livePanel = document.getElementById('livePricePanel');
      var subPanel = document.getElementById('subscriptionSummaryPanel');
      var nextPanel = document.getElementById('nextStepsPanel');
      if (livePanel) livePanel.hidden = onReview;
      if (subPanel) subPanel.hidden = !onReview;
      if (nextPanel) nextPanel.hidden = !onReview;

      syncActionBar();
      window.scrollTo({ top: wizardEl.offsetTop - 90, behavior: 'smooth' });
    }

    // ---- Persistent bottom action bar ----
    // The wizard keeps a single fixed Back/Continue bar. The per-panel
    // .wizard-nav buttons stay in the DOM (hidden via CSS) because other
    // scripts (register-submit.js) own #step2Continue and #wizardSubmit;
    // the bar simply mirrors and forwards to the active panel's controls.
    var actionBar = document.getElementById('wizardActionBar');
    var barBack = document.getElementById('wizardBarBack');
    var barNext = document.getElementById('wizardBarNext');

    function activePanel() {
      return wizardEl.querySelector('.wizard-panel[data-step="' + currentStep + '"]');
    }
    function panelPrimaryBtn() {
      var panel = activePanel();
      if (!panel) return null;
      return panel.querySelector('#wizardSubmit, [data-wizard-next]');
    }
    function panelBackBtn() {
      var panel = activePanel();
      if (!panel) return null;
      return panel.querySelector('[data-wizard-back]');
    }

    function syncActionBar() {
      if (!actionBar) return;
      var primary = panelPrimaryBtn();
      var back = panelBackBtn();

      if (barBack) {
        barBack.hidden = !back;
        barBack.disabled = back ? back.disabled : true;
      }
      if (barNext && primary) {
        barNext.textContent = (primary.textContent || 'Continue').trim() || 'Continue';
        barNext.disabled = primary.disabled;
      }
    }

    if (barNext) {
      barNext.addEventListener('click', function () {
        var primary = panelPrimaryBtn();
        if (primary && !primary.disabled) primary.click();
      });
    }
    if (barBack) {
      barBack.addEventListener('click', function () {
        var back = panelBackBtn();
        if (back && !back.disabled) back.click();
        else if (currentStep > 1) { currentStep--; renderStep(); }
      });
    }

    // Keep the bar's disabled state fresh while register-submit.js toggles
    // #step2Continue asynchronously (account gate / email verification).
    //
    // moTarget must be .layout-2col (the wizard panels + sidebar), NOT
    // wizardEl/#wizardForm: both of those also contain #wizardActionBar
    // itself, and syncActionBar() writes barBack.disabled/barNext.disabled
    // on every call - a `disabled`-attribute write inside the observed
    // subtree, which re-queues the very observer callback that just ran.
    // That turned every ordinary renderStep() (which calls syncActionBar()
    // as part of init) into an infinite mutate-observe-mutate loop that
    // froze the entire tab on load (Chrome's "Page Unresponsive" /
    // RESULT_CODE_HUNG - reproduced and bisected down to this exact block).
    // .layout-2col holds the real source of truth (the panels' own
    // buttons, e.g. #step2Continue) and never contains the action bar, so
    // the bar's own mirrored writes can no longer feed back into it.
    var moTarget = wizardEl.querySelector('.layout-2col');
    if (actionBar && moTarget && typeof MutationObserver !== 'undefined') {
      new MutationObserver(function () { syncActionBar(); })
        .observe(moTarget, { attributes: true, subtree: true, attributeFilter: ['disabled', 'class'] });
    }

    function fieldsForStep(step) {
      var panel = wizardEl.querySelector('.wizard-panel[data-step="' + step + '"]');
      if (!panel) return [];
      return Array.prototype.slice.call(panel.querySelectorAll('[required]'));
    }

    // A student count is valid only when it is a whole number >= 1.
    function isValidStudentCount(raw) {
      var str = String(raw == null ? '' : raw).trim();
      if (!/^\d+$/.test(str)) return false;
      return parseInt(str, 10) >= 1;
    }

    function validateStep(step) {
      var required = fieldsForStep(step);
      var valid = true;
      required.forEach(function (input) {
        var fieldEl = input.closest('.form-field') || input.parentElement;
        // A radio group (the term cards) is valid if any member is checked.
        var isRadio = input.type === 'radio';
        var value = isRadio
          ? (wizardEl.querySelector('[name="' + input.name + '"]:checked') ? 'x' : '')
          : (input.value || '').trim();
        fieldEl.classList.remove('has-error');
        if (!value) {
          fieldEl.classList.add('has-error');
          valid = false;
        } else if (input.type === 'email' && !window.SPForms.EMAIL_RE.test(value)) {
          fieldEl.classList.add('has-error');
          valid = false;
        } else if (input.name === 'studentCount' && !isValidStudentCount(value)) {
          fieldEl.classList.add('has-error');
          valid = false;
        }
      });

      // Step 3 also enforces the academic-calendar date rules once the
      // required fields above are all filled in.
      if (step === 3 && valid) {
        var calErr = validateAcademicCalendar();
        var errBox = document.getElementById('termDateError');
        if (calErr) {
          valid = false;
          if (errBox) { errBox.textContent = calErr; errBox.style.display = 'block'; }
        } else if (errBox) {
          errBox.textContent = ''; errBox.style.display = 'none';
        }
      }
      return valid;
    }

    // ---- Step 3: academic calendar (school year + term + dates) ----
    // Schools set their own term dates — nothing here assumes fixed Ugandan
    // term dates. The only structural rule is that a term's dates must fall
    // inside that term's third of the school year, so Term 1 / 2 / 3 can't
    // overlap each other.
    var TERM_WINDOWS = {
      'Term 1': { startMonth: 0, endMonth: 3 },   // Jan – Apr
      'Term 2': { startMonth: 4, endMonth: 7 },   // May – Aug
      'Term 3': { startMonth: 8, endMonth: 11 },  // Sep – Dec
    };

    function selectedTerm() {
      var el = wizardEl.querySelector('[name="term"]:checked');
      return el ? el.value : '';
    }

    // Parse a yyyy-mm-dd <input type=date> value into a local Date (midnight),
    // or null. Avoids new Date('yyyy-mm-dd') which parses as UTC.
    function parseDateInput(v) {
      var m = /^(\d{4})-(\d{2})-(\d{2})$/.exec((v || '').trim());
      if (!m) return null;
      var d = new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]));
      return isNaN(d.getTime()) ? null : d;
    }

    function fmtDate(d) {
      return d.toLocaleDateString('en-UG', { day: 'numeric', month: 'short', year: 'numeric' });
    }

    // Returns an error string, or '' when the calendar is valid.
    function validateAcademicCalendar() {
      var year = Number((wizardEl.querySelector('[name="schoolYear"]') || {}).value) || 0;
      var term = selectedTerm();
      var start = parseDateInput((wizardEl.querySelector('[name="termStart"]') || {}).value);
      var end = parseDateInput((wizardEl.querySelector('[name="termEnd"]') || {}).value);

      if (!year || !term || !start || !end) return '';

      if (end <= start) {
        return 'The term end date must be after the term start date.';
      }

      var yearStart = new Date(year, 0, 1);
      var yearEnd = new Date(year, 11, 31);
      if (start < yearStart || start > yearEnd || end < yearStart || end > yearEnd) {
        return 'Both dates must fall within the ' + year + ' school year.';
      }

      var w = TERM_WINDOWS[term];
      if (w) {
        var winStart = new Date(year, w.startMonth, 1);
        var winEnd = new Date(year, w.endMonth + 1, 0); // last day of end month
        if (start < winStart || end > winEnd) {
          return term + ' must fall between ' + fmtDate(winStart) + ' and ' +
            fmtDate(winEnd) + ' so it does not overlap the other terms. ' +
            'Adjust the dates or pick a different term.';
        }
      }
      return '';
    }

    // ---- Step 3: academic calendar preview panel ----
    function updateCalendarPreview() {
      var panel = document.getElementById('calendarPreviewPanel');
      var body = document.getElementById('calendarPreviewBody');
      if (!panel || !body) return;

      // Only surface the panel while the visitor is on the calendar step.
      panel.hidden = currentStep !== 3;
      if (currentStep !== 3) return;

      var term = selectedTerm();
      var start = parseDateInput((wizardEl.querySelector('[name="termStart"]') || {}).value);
      var end = parseDateInput((wizardEl.querySelector('[name="termEnd"]') || {}).value);

      // Calculations only appear once dates are present AND valid.
      if (!term || !start || !end || validateAcademicCalendar()) {
        body.innerHTML = '<p class="muted reg-preview-empty">Select a term and valid dates to see your calendar breakdown.</p>';
        return;
      }

      var msPerDay = 24 * 60 * 60 * 1000;
      var durationDays = Math.round((end - start) / msPerDay) + 1; // inclusive
      var totalWeeks = Math.ceil(durationDays / 7);

      var instructionalDays = 0;
      for (var d = new Date(start); d <= end; d = new Date(d.getTime() + msPerDay)) {
        var wd = d.getDay();
        if (wd !== 0 && wd !== 6) instructionalDays++; // Mon–Fri
      }

      body.innerHTML =
        '<div class="calendar-preview-term">' +
          '<span class="k">Selected term</span>' +
          '<span class="badge badge-blue">' + escapeHtml(term) + '</span>' +
        '</div>' +
        '<div class="summary-row"><span class="k">Start date</span><span class="v">' + fmtDate(start) + '</span></div>' +
        '<div class="summary-row"><span class="k">End date</span><span class="v">' + fmtDate(end) + '</span></div>' +
        '<div class="calendar-preview-gap"></div>' +
        '<div class="summary-row"><span class="k">Duration</span><span class="v">' + durationDays + ' days</span></div>' +
        '<div class="summary-row"><span class="k">Total weeks</span><span class="v">' + totalWeeks + ' weeks</span></div>' +
        '<div class="summary-row"><span class="k">Instructional days (Mon–Fri)</span><span class="v">' + instructionalDays + ' days</span></div>';
    }

    // Recompute the preview + clear stale inline errors as the visitor edits
    // any Step 3 field.
    ['schoolYear', 'term', 'termStart', 'termEnd'].forEach(function (name) {
      wizardEl.querySelectorAll('[name="' + name + '"]').forEach(function (el) {
        el.addEventListener('input', onCalendarFieldChange);
        el.addEventListener('change', onCalendarFieldChange);
      });
    });
    function onCalendarFieldChange() {
      var errBox = document.getElementById('termDateError');
      var calErr = validateAcademicCalendar();
      if (errBox) {
        if (calErr && (wizardEl.querySelector('[name="termStart"]').value) &&
            (wizardEl.querySelector('[name="termEnd"]').value) && selectedTerm()) {
          errBox.textContent = calErr; errBox.style.display = 'block';
        } else {
          errBox.textContent = ''; errBox.style.display = 'none';
        }
      }
      var fieldTerm = document.getElementById('fieldTerm');
      if (fieldTerm && selectedTerm()) fieldTerm.classList.remove('has-error');
      updateCalendarPreview();
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
    function setText(id, value) {
      var el = document.getElementById(id);
      if (el) el.textContent = value;
    }
    function bandRangeLabel(tier) {
      if (!tier) return '—';
      if (tier.max === null) return tier.min.toLocaleString('en-UG') + '+';
      return tier.min.toLocaleString('en-UG') + ' – ' + tier.max.toLocaleString('en-UG');
    }

    // Step 4 "What's included" list follows the matched plan.
    function renderIncludes(tier) {
      var list = document.getElementById('estIncludes');
      if (!list || !tier || !tier.includes) return;
      var tickHtml = (window.ICONS && window.ICONS.check) || '';
      list.innerHTML = '';
      tier.includes.forEach(function (item) {
        var li = document.createElement('li');
        var t = document.createElement('span');
        t.className = 'price-tick';
        t.innerHTML = tickHtml;
        li.appendChild(t);
        li.appendChild(document.createTextNode(' ' + item));
        list.appendChild(li);
      });
    }

    function updatePriceSummary() {
      var countInput = wizardEl.querySelector('[name="studentCount"]');
      if (!countInput) return;

      var raw = (countInput.value || '').trim();
      var valid = isValidStudentCount(raw);
      var count = valid ? parseInt(raw, 10) : 0;
      var tier = valid ? window.getTierForCount(count) : null;

      // Legacy sidebar summary (kept in DOM for any other page hooks).
      var summaryCount = document.getElementById('summaryStudentCount');
      var summaryTier = document.getElementById('summaryTier');
      var summaryPrice = document.getElementById('summaryPrice');
      if (summaryPrice) {
        if (!valid) {
          if (summaryCount) summaryCount.textContent = '—';
          if (summaryTier) summaryTier.textContent = '—';
          summaryPrice.textContent = 'Enter student count';
        } else {
          if (summaryCount) summaryCount.textContent = count.toLocaleString('en-UG');
          if (summaryTier) summaryTier.textContent = tier.label;
          summaryPrice.textContent = tier.price === null
            ? 'Talk to us'
            : window.formatUGX(tier.price) + ' / term';
        }
      }

      // Step 4 estimate card.
      var estAmount = document.getElementById('estAmount');
      if (estAmount) {
        var estSub = document.getElementById('estAmountSub');
        var bandNote = document.getElementById('estBandNote');
        if (!valid) {
          setText('estStudents', '—');
          setText('estBand', '—');
          setText('estUnit', ' ');
          estAmount.textContent = 'Enter a student count';
          estAmount.classList.remove('price-amount--num');
          if (estSub) estSub.hidden = true;
          if (bandNote) bandNote.hidden = true;
        } else {
          setText('estStudents', count.toLocaleString('en-UG'));
          setText('estBand', bandRangeLabel(tier));
          if (tier.price === null) {
            setText('estUnit', 'Custom');
            estAmount.textContent = 'Custom pricing';
            estAmount.classList.remove('price-amount--num');
            if (estSub) { estSub.hidden = false; estSub.textContent = "we'll tailor this with you"; }
          } else {
            setText('estUnit', window.formatUGX(tier.price));
            estAmount.textContent = window.formatUGX(tier.price);
            estAmount.classList.add('price-amount--num');
            if (estSub) { estSub.hidden = false; estSub.textContent = 'per term'; }
          }
          if (bandNote) bandNote.hidden = false;
          renderIncludes(tier);
        }
      }
    }
    var studentCountInput = wizardEl.querySelector('[name="studentCount"]');
    if (studentCountInput) {
      studentCountInput.addEventListener('input', updatePriceSummary);

      // Increment / decrement stepper controls.
      function nudgeCount(delta) {
        var cur = parseInt((studentCountInput.value || '').trim(), 10);
        if (isNaN(cur)) cur = 0;
        var next = Math.max(1, cur + delta);
        studentCountInput.value = String(next);
        studentCountInput.dispatchEvent(new Event('input', { bubbles: true }));
        var fieldEl = studentCountInput.closest('.form-field');
        if (fieldEl) fieldEl.classList.remove('has-error');
      }
      var upBtn = document.getElementById('studentCountUp');
      var downBtn = document.getElementById('studentCountDown');
      if (upBtn) upBtn.addEventListener('click', function () { nudgeCount(1); });
      if (downBtn) downBtn.addEventListener('click', function () { nudgeCount(-1); });

      // Block decimal / negative / exponent key entry outright.
      studentCountInput.addEventListener('keydown', function (e) {
        if (['e', 'E', '+', '-', '.', ','].indexOf(e.key) !== -1) e.preventDefault();
      });
      studentCountInput.addEventListener('blur', function () {
        var str = (studentCountInput.value || '').trim();
        if (str === '') return;
        var n = parseInt(str, 10);
        if (isNaN(n) || n < 1) { studentCountInput.value = ''; }
        else { studentCountInput.value = String(n); }
        updatePriceSummary();
        saveDraft();
      });
    }

    // ---- Review step (Step 6): four collapsible summary cards ----
    // Each card's body is a two-column key/value grid built live from the
    // form fields, so the visitor's draft is always the source of truth and
    // an Edit round-trip that changes a value is reflected on return.
    function fieldValue(name) {
      if (name === 'term') return selectedTerm();
      var input = wizardEl.querySelector('[name="' + name + '"]');
      return input ? (input.value || '').trim() : '';
    }

    function kvGrid(pairs) {
      var cells = '';
      pairs.forEach(function (p) {
        var value = p[2] != null ? p[2] : fieldValue(p[1]);
        if (!value) return;
        cells +=
          '<div class="review-kv">' +
            '<span class="review-kv-k">' + escapeHtml(p[0]) + '</span>' +
            '<span class="review-kv-v">' + escapeHtml(value) + '</span>' +
          '</div>';
      });
      return cells
        ? '<div class="review-kv-grid">' + cells + '</div>'
        : '<p class="muted review-kv-empty">Nothing entered for this section yet.</p>';
    }

    function fmtDateStr(v) {
      var d = parseDateInput(v);
      return d ? fmtDate(d) : (v || '');
    }

    function renderReview() {
      var schoolBody = document.getElementById('reviewBodySchool');
      var adminBody = document.getElementById('reviewBodyAdmin');
      var calBody = document.getElementById('reviewBodyCalendar');
      var locBody = document.getElementById('reviewBodyLocation');
      if (!schoolBody || !adminBody || !calBody || !locBody) return;

      schoolBody.innerHTML = kvGrid([
        ['School name', 'schoolName'],
        ['School initials', 'schoolPrefix'],
        ['School type', 'schoolType'],
        ['Curriculum', 'curriculum'],
        ['School email', 'schoolEmail'],
        ['School phone', 'schoolPhone'],
        ['School website', 'schoolWebsite'],
      ]);

      adminBody.innerHTML = kvGrid([
        ['Administrator name', 'adminName'],
        ['Email address', 'adminEmail'],
        ['Phone number', 'adminPhone'],
        ['Administrator role', 'adminRole'],
      ]);

      calBody.innerHTML = kvGrid([
        ['School year', 'schoolYear'],
        ['Current term', 'term'],
        ['Term start date', null, fmtDateStr(fieldValue('termStart'))],
        ['Term end date', null, fmtDateStr(fieldValue('termEnd'))],
      ]);

      var subdomain = fieldValue('subdomain');
      locBody.innerHTML = kvGrid([
        ['Region', 'region'],
        ['District', 'district'],
        ['School address', 'address'],
        ['Subdomain', null, subdomain ? subdomain + '.schoolpulseapp.com' : ''],
      ]);

      renderSubscriptionSummary();
    }

    // Right-hand "Termly subscription summary" panel (Step 6 only).
    function renderSubscriptionSummary() {
      var raw = fieldValue('studentCount');
      var valid = isValidStudentCount(raw);
      var count = valid ? parseInt(raw, 10) : 0;
      var tier = valid ? window.getTierForCount(count) : null;
      var term = selectedTerm();
      var year = fieldValue('schoolYear');

      setText('subSummaryStudents', valid ? count.toLocaleString('en-UG') : '—');
      setText('subSummaryBand', tier
        ? tier.label + ' (' + bandRangeLabel(tier) + ' students)'
        : '—');
      setText('subSummaryPrice', tier
        ? (tier.price === null ? 'Custom' : window.formatUGX(tier.price))
        : '—');
      setText('subSummaryTerm', (term && year) ? (term + ' (' + year + ')') : (term || year || '—'));

      var perEl = document.querySelector('.sub-summary-per');
      if (perEl) perEl.style.display = (tier && tier.price !== null) ? '' : 'none';
    }

    // ---- Step 6: collapsible cards + Edit links ----
    function initReviewCards() {
      var container = document.getElementById('reviewCards');
      if (!container) return;

      container.querySelectorAll('.review-card-head').forEach(function (head) {
        head.addEventListener('click', function (e) {
          // The Edit link lives inside the header button; let it do its own thing.
          if (e.target.closest('.review-card-edit')) return;
          var card = head.closest('.review-card');
          var open = head.getAttribute('aria-expanded') === 'true';
          head.setAttribute('aria-expanded', open ? 'false' : 'true');
          card.classList.toggle('is-collapsed', open);
        });
      });

      container.querySelectorAll('.review-card-edit').forEach(function (link) {
        link.addEventListener('click', function (e) {
          e.preventDefault();
          e.stopPropagation();
          var step = Number(link.getAttribute('data-edit-step')) || 1;
          // Draft is already persisted on every input; jumping back keeps it.
          currentStep = Math.min(Math.max(step, 1), TOTAL_STEPS);
          renderStep();
        });
      });
    }

    // ---- Step 6: terms-acceptance gate ----
    // The backend requires termsAccepted on the application, so this checkbox
    // is a real gate: Submit stays disabled until it is ticked.
    function initConsentGate() {
      var box = document.getElementById('termsAccept');
      var submitBtn = document.getElementById('wizardSubmit');
      var consent = document.getElementById('reviewConsent');
      if (!box || !submitBtn) return;

      function sync() {
        submitBtn.disabled = !box.checked;
        if (box.checked && consent) consent.classList.remove('has-error');
        syncActionBar();
      }
      box.addEventListener('change', sync);
      // Restore from a saved draft, then set the initial disabled state.
      sync();

      // If the visitor tries the (disabled) Submit via the action bar, flag it.
      var barNextBtn = document.getElementById('wizardBarNext');
      if (barNextBtn) {
        barNextBtn.addEventListener('click', function () {
          if (currentStep === TOTAL_STEPS && !box.checked && consent) {
            consent.classList.add('has-error');
          }
        });
      }
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

    initReviewCards();
    loadDraft();
    initConsentGate();
    renderStep();
  }

  document.addEventListener('DOMContentLoaded', initWizard);
})();
