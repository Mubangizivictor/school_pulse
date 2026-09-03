// Wires register-school.html's wizard to the real backend:
//   - account creation + email verification gate in Step 2 (Administrator),
//     via SPAuth (js/registration-auth.js) — the same Firebase SDK
//     lazy-load / callFunction pattern payment.html and
//     application-status.html already use.
//   - district -> region auto-fill in Step 5 (Address & subdomain), for the
//     districts already in the existing <select>; "Other" leaves the region
//     select for the visitor to pick themselves.
//   - the real Step 6 submit: builds the exact submitSchoolApplication body
//     shape, maps the wizard's pricing tier label to the backend's plan
//     enum, blocks submission for the "Custom"/1201+ tier (no fixed price
//     to submit), and handles every documented error code inline.
(function () {
  // Mirrors public_functions/uganda_regions.json's mapping for exactly the
  // districts offered in the Step 5 <select> today. Not a full copy of the
  // backend's district list — if "Other" is chosen the visitor picks their
  // own region, so this table only needs to cover the fixed options above.
  var DISTRICT_REGION = {
    Kampala: 'Central',
    Wakiso: 'Central',
    Mukono: 'Central',
    Jinja: 'Eastern',
    Mbarara: 'Western',
  };

  // Marketing site shows 5 tiers (incl. "Custom" for 1201+); the backend's
  // `plan` field only accepts Starter/Growth/Pro/Enterprise. "Standard" is
  // the marketing label for what the backend calls "Pro" — there are 4
  // paid backend plans and 4 self-serve marketing tiers below Custom, so
  // this is a 1:1 rename, not a lossy collapse. "Custom" has no backend
  // plan value at all (no fixed price) and is handled as a hard block
  // before reaching submit, never coerced into one of the 4 allowed values.
  var TIER_LABEL_TO_PLAN = {
    Starter: 'Starter',
    Growth: 'Growth',
    Standard: 'Pro',
    Enterprise: 'Enterprise',
  };

  function byName(name) {
    var wizardEl = document.getElementById('registerWizard');
    return wizardEl ? wizardEl.querySelector('[name="' + name + '"]') : null;
  }
  function val(name) {
    var el = byName(name);
    return el ? (el.value || '').trim() : '';
  }

  // ---- Step 5: district -> region auto-fill ----
  function initRegionAutofill() {
    var districtEl = byName('district');
    var regionEl = byName('region');
    if (!districtEl || !regionEl) return;
    districtEl.addEventListener('change', function () {
      var mapped = DISTRICT_REGION[districtEl.value];
      if (mapped) regionEl.value = mapped;
      // "Other" (or any unmapped district): leave whatever the visitor has
      // already chosen, or blank, for them to fill in themselves.
    });
  }

  // ---- Step 2: account creation + email verification ----
  var verified = false;
  var pollTimer = null;

  function initAccountGate() {
    var createPanel = document.getElementById('accountCreatePanel');
    var verifyPanel = document.getElementById('accountVerifyPanel');
    var verifiedPanel = document.getElementById('accountVerifiedPanel');
    var createBtn = document.getElementById('createAccountBtn');
    var resendBtn = document.getElementById('resendVerificationBtn');
    var checkBtn = document.getElementById('checkVerifiedBtn');
    var errorEl = document.getElementById('accountError');
    var pwField = document.getElementById('fieldAccountPassword');
    if (!createPanel || !createBtn) return;

    function showPanel(which) {
      createPanel.style.display = which === 'create' ? 'block' : 'none';
      verifyPanel.style.display = which === 'verify' ? 'block' : 'none';
      verifiedPanel.style.display = which === 'verified' ? 'block' : 'none';
    }

    function markVerified(email) {
      verified = true;
      if (pollTimer) { clearInterval(pollTimer); pollTimer = null; }
      document.getElementById('accountVerifiedEmail').textContent = email || '';
      showPanel('verified');
    }

    function setError(msg) {
      errorEl.textContent = msg;
      errorEl.style.display = msg ? 'block' : 'none';
    }

    createBtn.addEventListener('click', function () {
      setError('');
      var email = val('adminEmail');
      var password = document.getElementById('accountPassword').value;
      pwField.classList.remove('has-error');

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        setError('Enter a valid administrator email above first.');
        return;
      }
      if (!password || password.length < 8) {
        pwField.classList.add('has-error');
        return;
      }

      createBtn.disabled = true;
      createBtn.textContent = 'Creating account…';

      SPAuth.ensureFirebase().then(function (firebase) {
        return firebase.auth().createUserWithEmailAndPassword(email, password).catch(function (err) {
          // Account may already exist from an earlier attempt on this
          // wizard (e.g. the visitor navigated away and came back) — try
          // signing in with the same password instead of hard-failing.
          if (err && err.code === 'auth/email-already-in-use') {
            return firebase.auth().signInWithEmailAndPassword(email, password);
          }
          return Promise.reject(err);
        }).then(function (cred) {
          var user = cred.user;
          if (user.emailVerified) {
            markVerified(user.email);
            return;
          }
          return user.sendEmailVerification().then(function () {
            document.getElementById('accountVerifyMsg').innerHTML =
              'We sent a verification link to <strong>' + email + '</strong>. Open it, then come back and click below.';
            showPanel('verify');
          });
        });
      }).catch(function (err) {
        var msg = 'Could not create your account. Please try again.';
        if (err && err.code === 'auth/email-already-in-use') msg = 'An account already exists for this email with a different password. Try a different password or sign in on the app.';
        else if (err && err.code === 'auth/weak-password') msg = 'Please choose a stronger password (at least 8 characters).';
        else if (err && err.code === 'auth/invalid-email') msg = 'That email address looks invalid.';
        else if (err && err.code === 'auth/wrong-password') msg = 'An account already exists for this email, but that password is incorrect.';
        setError(msg);
      }).finally(function () {
        createBtn.disabled = false;
        createBtn.textContent = 'Create account & send verification email';
      });
    });

    resendBtn.addEventListener('click', function () {
      resendBtn.disabled = true;
      resendBtn.textContent = 'Sending…';
      SPAuth.ensureFirebase().then(function (firebase) {
        var user = firebase.auth().currentUser;
        if (!user) return Promise.reject(new Error('not_signed_in'));
        return user.sendEmailVerification();
      }).catch(function () {
        // Best-effort — Firebase rate-limits repeated sends; not worth a
        // hard error state here, the visitor can just try again shortly.
      }).finally(function () {
        resendBtn.disabled = false;
        resendBtn.textContent = 'Resend verification email';
      });
    });

    checkBtn.addEventListener('click', function () {
      checkBtn.disabled = true;
      checkBtn.textContent = 'Checking…';
      SPAuth.ensureFirebase().then(function (firebase) {
        var user = firebase.auth().currentUser;
        if (!user) return Promise.reject(new Error('not_signed_in'));
        return user.reload().then(function () {
          if (user.emailVerified) {
            markVerified(user.email);
          } else {
            document.getElementById('accountVerifyMsg').innerHTML =
              'Still not verified yet. Check your inbox (and spam folder), click the link, then try again.';
          }
        });
      }).catch(function () {}).finally(function () {
        checkBtn.disabled = false;
        checkBtn.textContent = "I've verified — continue";
      });
    });

    // If a user already has a verified session (e.g. came back to this
    // page later), skip straight to the verified state.
    SPAuth.currentUser().then(function (user) {
      if (user && user.emailVerified && val('adminEmail') && user.email.toLowerCase() === val('adminEmail').toLowerCase()) {
        markVerified(user.email);
      }
    });
  }

  // ---- Step 6: real submit ----
  function buildBody() {
    var studentCount = Number(val('studentCount')) || 0;
    var tier = window.getTierForCount(studentCount);
    var plan = TIER_LABEL_TO_PLAN[tier.label];
    return {
      body: {
        school: {
          name: val('schoolName'),
          shortName: val('schoolPrefix'),
          email: val('schoolEmail'),
          phone: val('schoolPhone'),
          prefix: val('schoolPrefix'),
          category: val('schoolType'),
          studentCapacity: studentCount,
          slug: (val('subdomain') || '').toLowerCase().replace(/[^a-z0-9-]/g, ''),
        },
        location: {
          region: val('region'),
          district: val('district'),
          address: val('address'),
        },
        administrator: {
          firstName: (val('adminName').split(' ')[0] || val('adminName')),
          lastName: (val('adminName').split(' ').slice(1).join(' ') || val('adminName')),
          phone: val('adminPhone'),
          email: val('adminEmail'),
        },
        plan: plan,
        selectedModules: [],
        termsAccepted: true,
        marketingOptIn: false,
      },
      plan: plan,
      tier: tier,
      studentCount: studentCount,
    };
  }

  var ERROR_MESSAGES = {
    verified_auth_required: 'Please verify your email above before submitting.',
    invalid_application: 'Some of the information entered looks invalid or incomplete. Please review each step and try again.',
    application_exists: 'You already have a School Pulse application submitted with this account. Check your application status instead.',
    prefix_in_use: 'Those school initials are already in use by another School Pulse school. Please choose different initials in Step 1.',
    school_phone_in_use: 'That school phone number is already linked to another School Pulse application.',
    admin_phone_in_use: 'That administrator phone number is already linked to another School Pulse school.',
    school_email_in_use: 'That school email is already linked to another School Pulse application.',
    slug_in_use: 'That web address is already taken. Please choose another subdomain in Step 5.',
    too_many_requests: 'Too many attempts. Please wait a bit and try again.',
  };

  function initSubmit() {
    var submitBtn = document.getElementById('wizardSubmit');
    if (!submitBtn) return;
    var customNotice = document.getElementById('customTierNotice');
    var verifyNotice = document.getElementById('verificationNotice');
    var submitError = document.getElementById('submitError');
    var submitting = false;

    function setError(msg) {
      submitError.textContent = msg;
      submitError.style.display = msg ? 'block' : 'none';
    }

    submitBtn.addEventListener('click', function () {
      if (submitting) return;
      customNotice.style.display = 'none';
      verifyNotice.style.display = 'none';
      setError('');

      var built = buildBody();

      if (!built.plan) {
        // Custom/1201+ tier — no fixed price, cannot self-serve-submit.
        customNotice.style.display = 'block';
        return;
      }
      if (!verified) {
        verifyNotice.style.display = 'block';
        // Send the visitor back to the account step rather than just
        // showing a message they might not connect to Step 2.
        if (window.SPWizard) window.SPWizard.goToStep(2);
        return;
      }

      submitting = true;
      submitBtn.disabled = true;
      submitBtn.textContent = 'Submitting…';

      SPAuth.callFunction('submitSchoolApplication', { method: 'POST', body: built.body }).then(function (data) {
        document.getElementById('wizardForm').style.display = 'none';
        document.getElementById('wizardSuccess').style.display = 'block';
        document.getElementById('wizardSuccessId').textContent =
          'Application ID: ' + (data && data.applicationId ? data.applicationId : '—');
        try { localStorage.removeItem(window.SPWizard ? window.SPWizard.getStorageKey() : 'sp_register_school_draft_v1'); } catch (e) {}
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }).catch(function (err) {
        var code = err && err.error;
        setError((code && ERROR_MESSAGES[code]) || (err && err.message) || 'Could not submit your registration. Please try again.');
      }).finally(function () {
        submitting = false;
        submitBtn.disabled = false;
        submitBtn.textContent = 'Submit registration';
      });
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initRegionAutofill();
    initAccountGate();
    initSubmit();
  });
})();
