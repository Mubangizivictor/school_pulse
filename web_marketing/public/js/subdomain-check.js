// Live subdomain-availability check on register-school.html's step 5,
// backed by the real public checkPortalSlug callable
// (public_functions/portal_domains.js) - no auth required, and this is the
// exact same reservation namespace approveSchoolApplication later commits
// the chosen slug into, so a "yes, available" answer here is meaningful.
//
// checkPortalSlug is a Cloud Functions v2 onCall, not one of the onRequest
// REST endpoints registration-auth.js's SPAuth.callFunction targets - onCall
// uses Firebase's callable wire protocol ({"data": ...} in, {"result": ...}
// out), so this talks to it directly rather than reusing that helper.
(function () {
  var FUNCTIONS_BASE = 'https://europe-west1-school-pulse-3d95b.cloudfunctions.net';
  // Localhost -> Functions emulator, matching registration-auth.js.
  if (/^(localhost|127\.0\.0\.1)$/.test(window.location.hostname)) {
    FUNCTIONS_BASE = 'http://127.0.0.1:5001/school-pulse-3d95b/europe-west1';
  }
  var DEBOUNCE_MS = 450;

  // Sanitizes free-typed input down to the charset the backend accepts
  // (public_functions/portal_slug.js's validSlug: lowercase letters,
  // digits, hyphens). This is the one place that logic lives on this
  // static site (no build step to share a Node module with the backend
  // across the two runtimes) - register-submit.js reuses this exact
  // function via window.SPSlug.sanitize rather than re-implementing it,
  // so the live-checked slug and the submitted slug can never disagree.
  function sanitize(raw) {
    return (raw || '').toLowerCase().replace(/[^a-z0-9-]/g, '');
  }
  window.SPSlug = { sanitize: sanitize };

  function checkPortalSlug(slug) {
    return fetch(FUNCTIONS_BASE + '/checkPortalSlug', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ data: { slug: slug } }),
    }).then(function (res) {
      return res.json().then(function (body) {
        if (!res.ok) return Promise.reject(body);
        return body.result || body;
      });
    });
  }

  var CHECK_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>';
  var X_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18M6 6l12 12"/></svg>';

  function init() {
    var input = document.getElementById('subdomain');
    var preview = document.getElementById('subdomainPreview');
    var status = document.getElementById('subdomainStatus');
    var pill = document.getElementById('subdomainResult');
    var field = document.getElementById('fieldSubdomain');
    if (!input || !status) return;

    var timer = null;
    var latestSlug = null;

    function renderPill(state, label) {
      if (!pill) return;
      if (state === 'idle') { pill.hidden = true; pill.innerHTML = ''; return; }
      pill.hidden = false;
      pill.className = 'subdomain-result ' +
        (state === 'available' ? 'is-available'
          : state === 'unavailable' ? 'is-unavailable'
          : 'is-checking');
      var ico = state === 'available' ? CHECK_ICON
        : state === 'unavailable' ? X_ICON : '';
      pill.innerHTML = ico + '<span>' + label + '</span>';
    }

    function render(state, message) {
      status.textContent = message;
      status.style.color = state === 'available'
        ? 'var(--color-success)'
        : state === 'unavailable'
          ? 'var(--color-error)'
          : 'var(--color-muted)';
      if (field) {
        field.classList.toggle('has-error', state === 'unavailable');
      }
      renderPill(
        state === 'available' ? 'available'
          : state === 'unavailable' ? 'unavailable'
          : state === 'checking' ? 'checking'
          : 'idle',
        state === 'available' ? 'Available'
          : state === 'unavailable' ? 'Unavailable'
          : 'Checking…'
      );
    }

    function runCheck() {
      var raw = sanitize(input.value);
      if (preview) preview.textContent = (raw || 'yourschool') + '.schoolpulseapp.com';
      if (!raw) { render('idle', ''); return; }

      latestSlug = raw;
      render('checking', 'Checking availability…');
      checkPortalSlug(raw).then(function (result) {
        if (raw !== latestSlug) return; // a newer keystroke has since fired
        if (result.available) {
          render('available', 'Great — ' + raw + '.schoolpulseapp.com is available.');
        } else if (result.reason === 'invalid_or_reserved') {
          render('unavailable', 'That web address isn’t available. Try letters, numbers and hyphens only.');
        } else {
          render('unavailable', 'That web address is already taken. Try another.');
        }
      }).catch(function () {
        if (raw !== latestSlug) return;
        render('unavailable', 'Could not check availability right now. You can still continue — we’ll confirm it during review.');
      });
    }

    input.addEventListener('input', function () {
      if (timer) clearTimeout(timer);
      timer = setTimeout(runCheck, DEBOUNCE_MS);
    });

    if (input.value) runCheck();
  }

  document.addEventListener('DOMContentLoaded', init);
})();
