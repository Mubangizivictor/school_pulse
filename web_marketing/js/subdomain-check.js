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

  function init() {
    var input = document.getElementById('subdomain');
    var preview = document.getElementById('subdomainPreview');
    var status = document.getElementById('subdomainStatus');
    if (!input || !status) return;

    var timer = null;
    var latestSlug = null;

    function render(state, message) {
      status.textContent = message;
      status.style.color = state === 'available'
        ? 'var(--color-success)'
        : state === 'unavailable'
          ? 'var(--color-error)'
          : 'var(--color-muted)';
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
