// Wires register-school.html's wizard to the real backend:
//   - account creation + email verification gate in Step 2 (Administrator),
//     via SPAuth (js/registration-auth.js) — the same Firebase SDK
//     lazy-load / callFunction pattern payment.html and
//     application-status.html already use.
//   - region -> district cascade in Step 5 (Address & subdomain): choosing a
//     region populates the district <input list> with only that region's
//     districts, so the visitor can't pick a mismatched pair.
//   - the real Step 6 submit: builds the exact submitSchoolApplication body
//     shape, maps the wizard's pricing tier label to the backend's plan
//     enum, blocks submission for the Enterprise/1501+ tier (no fixed price
//     to submit), and handles every documented error code inline.
(function () {
  // Full district list per region, generated from
  // public_functions/uganda_regions.json (the backend's own source of
  // truth for district -> region, used to validate submitted applications).
  // Two corrections vs. that raw file: "Ssembabule" is dropped as a
  // duplicate spelling of "Sembabule", and "Kagame" is dropped as a data
  // error (not a real Uganda district) — neither should reach visitors.
  var DISTRICTS_BY_REGION = {
    Central: ['Buikwe', 'Bukomansimbi', 'Butambala', 'Buvuma', 'Gomba', 'Kalangala', 'Kalungu', 'Kampala', 'Kayunga', 'Kiboga', 'Kyankwanzi', 'Kyotera', 'Luwero', 'Lyantonde', 'Masaka', 'Mityana', 'Mpigi', 'Mubende', 'Mukono', 'Nakaseke', 'Nakasongola', 'Rakai', 'Sembabule', 'Wakiso'],
    Eastern: ['Amuria', 'Budaka', 'Bududa', 'Bugiri', 'Bukwo', 'Bulambuli', 'Busia', 'Butaleja', 'Buyende', 'Iganga', 'Jinja', 'Kaberamaido', 'Kalaki', 'Kaliro', 'Kamuli', 'Kapchorwa', 'Katakwi', 'Kibuku', 'Kween', 'Luuka', 'Manafwa', 'Mayuge', 'Mbale', 'Namayingo', 'Namisindwa', 'Namutumba', 'Ngora', 'Pallisa', 'Serere', 'Sironko', 'Soroti', 'Tororo'],
    Northern: ['Abim', 'Adjumani', 'Agago', 'Alebtong', 'Amolatar', 'Amudat', 'Amuru', 'Apac', 'Arua', 'Dokolo', 'Gulu', 'Kaabong', 'Kitgum', 'Koboko', 'Kole', 'Kotido', 'Lamwo', 'Lira', 'Madi-Okollo', 'Maracha', 'Moroto', 'Moyo', 'Nakapiripirit', 'Napak', 'Nebbi', 'Nwoya', 'Obongi', 'Omoro', 'Otuke', 'Oyam', 'Pader', 'Pakwach', 'Terego', 'Yumbe', 'Zombo'],
    Western: ['Buhweju', 'Buliisa', 'Bundibugyo', 'Bunyangabu', 'Bushenyi', 'Fort Portal', 'Hoima', 'Ibanda', 'Isingiro', 'Kabale', 'Kabarole', 'Kagadi', 'Kakumiro', 'Kamwenge', 'Kanungu', 'Kasese', 'Kibaale', 'Kikuube', 'Kiruhura', 'Kisoro', 'Kyegegwa', 'Kyenjojo', 'Masindi', 'Mbarara', 'Mitooma', 'Ntoroko', 'Ntungamo', 'Rubirizi', 'Rukiga', 'Rukungiri', 'Rwampara', 'Sheema'],
  };

  // Each pricing tier carries its backend plan enum (Starter/Growth/Pro) in
  // pricing-config.js. Enterprise has no plan value (no fixed price) and is
  // handled as a hard block before reaching submit, never coerced into one
  // of the allowed values.

  function byName(name) {
    var wizardEl = document.getElementById('registerWizard');
    return wizardEl ? wizardEl.querySelector('[name="' + name + '"]') : null;
  }
  function val(name) {
    var el = byName(name);
    return el ? (el.value || '').trim() : '';
  }

  // ---- Step 5: region -> district cascade ----
  function initRegionDistrictCascade() {
    var regionEl = byName('region');
    var districtEl = byName('district');
    var districtList = document.getElementById('districtOptions');
    if (!regionEl || !districtEl || !districtList) return;

    // preserveValue: true when repopulating for a region restored from a
    // saved draft (wizard.js's loadDraft sets .value directly without
    // firing 'change') - the district value it also restored is already
    // known-valid for that region since it was only ever saved after
    // passing the same pairing this cascade enforces, so it must survive
    // this repopulation rather than being wiped like a fresh region pick.
    function populateDistricts(preserveValue) {
      var currentValue = districtEl.value;
      var districts = DISTRICTS_BY_REGION[regionEl.value] || [];
      districtList.innerHTML = '';
      districts.forEach(function (name) {
        var opt = document.createElement('option');
        opt.value = name;
        districtList.appendChild(opt);
      });
      districtEl.value = preserveValue ? currentValue : '';
      districtEl.disabled = districts.length === 0;
      districtEl.placeholder = districts.length
        ? 'Start typing your district…'
        : 'Select a region first';
    }

    regionEl.addEventListener('change', function () { populateDistricts(false); });
    // Restores the datalist for a region+district pair loaded from a saved
    // draft (see loadDraft() in wizard.js) before the visitor interacts.
    if (regionEl.value) populateDistricts(true);

    // A visitor who picks a district then goes back and changes region
    // shouldn't be able to submit a now-mismatched pair — re-validated
    // again at submit time regardless, this just clears it eagerly.
    districtEl.addEventListener('blur', function () {
      var districts = DISTRICTS_BY_REGION[regionEl.value] || [];
      if (districtEl.value && districts.indexOf(districtEl.value) === -1) {
        districtEl.value = '';
      }
    });
  }

  // ---- Step 2: account creation + email verification ----
  var verified = false;
  var pollTimer = null;
  var countdownTimer = null;
  var RESEND_SECONDS = 60;

  function initAccountGate() {
    var createPanel = document.getElementById('accountCreatePanel');   // "Secure your account"
    var verifiedPanel = document.getElementById('accountVerifiedPanel'); // "Email verified"
    var verifyCard = document.getElementById('accountVerifyPanel');     // "Check your email" dialog
    var verifyBackdrop = document.getElementById('verifyDialogBackdrop');
    var createBtn = document.getElementById('createAccountBtn');
    var resendBtn = document.getElementById('resendVerificationBtn');
    var checkBtn = document.getElementById('checkVerifiedBtn');
    var changeEmailBtn = document.getElementById('changeEmailBtn');
    var verifyCloseBtn = document.getElementById('verifyClose');
    var continueBtn = document.getElementById('step2Continue');
    var errorEl = document.getElementById('accountError');
    var pwField = document.getElementById('fieldAccountPassword');
    var pwInput = document.getElementById('accountPassword');
    var pwToggle = document.getElementById('pwToggle');
    var pwMeter = document.getElementById('pwMeter');
    var pwStatus = document.getElementById('pwStatus');
    var verifyMsgEl = document.getElementById('accountVerifyMsg');
    var verifyEmailEl = document.getElementById('verifyEmail');
    var countdownEl = document.getElementById('resendCountdown');
    var verifyFootEl = document.getElementById('verifyFoot');
    if (!createPanel || !createBtn) return;

    // ---- password: show/hide + strength meter ----
    if (pwToggle && pwInput) {
      pwToggle.addEventListener('click', function () {
        var show = pwInput.type === 'password';
        pwInput.type = show ? 'text' : 'password';
        pwToggle.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
      });
    }
    function scorePassword(pw) {
      if (!pw) return 0;
      var score = 0;
      if (pw.length >= 8) score++;
      if (pw.length >= 12) score++;
      if (/[a-z]/.test(pw) && /[A-Z]/.test(pw)) score++;
      if (/\d/.test(pw)) score++;
      if (/[^A-Za-z0-9]/.test(pw)) score++;
      return Math.min(score, 4);
    }
    function renderStrength() {
      if (!pwMeter || !pwInput) return;
      var pw = pwInput.value;
      var s = scorePassword(pw);
      pwMeter.className = 'pw-meter' + (pw ? ' s' + s : '');
      if (!pwStatus) return;
      if (pw && pw.length >= 8 && s >= 3) {
        pwStatus.innerHTML = '<span class="ok">' +
          ((window.ICONS && window.ICONS.check) || '') + 'Strong password</span>';
      } else if (pw && pw.length >= 8) {
        pwStatus.innerHTML = '<span class="hint">Add capitals, numbers or symbols to strengthen it.</span>';
      } else {
        pwStatus.innerHTML = '<span class="hint">Use at least 8 characters with a mix of letters, numbers and symbols.</span>';
      }
    }
    if (pwInput) pwInput.addEventListener('input', renderStrength);
    renderStrength();

    // ---- which of the three account states is visible ----
    // create  -> "Secure your account" panel + disabled Continue
    // verify  -> "Check your email" dialog (bottom sheet on mobile) + disabled Continue
    // verified-> "Email verified" panel + enabled Continue
    // Only one action set is ever shown at once (no simultaneous
    // "Create account" / "I've verified" / "Save and continue").
    function showState(which) {
      createPanel.style.display = which === 'create' ? '' : 'none';
      verifiedPanel.style.display = which === 'verified' ? '' : 'none';
      if (verifyCard) verifyCard.hidden = which !== 'verify';
      if (verifyBackdrop) verifyBackdrop.hidden = which !== 'verify';
      if (continueBtn) continueBtn.disabled = which !== 'verified';
      if (which !== 'verify') stopCountdown();
    }

    function markVerified(email) {
      verified = true;
      if (pollTimer) { clearInterval(pollTimer); pollTimer = null; }
      var el = document.getElementById('accountVerifiedEmail');
      if (el) el.textContent = email || '';
      showState('verified');
    }

    function setError(msg) {
      errorEl.textContent = msg;
      errorEl.style.display = msg ? 'block' : 'none';
    }
    function setVerifyMsg(msg, isError) {
      if (!verifyMsgEl) return;
      verifyMsgEl.textContent = msg || '';
      verifyMsgEl.style.display = msg ? 'block' : 'none';
      verifyMsgEl.classList.toggle('is-error', !!isError);
    }

    // ---- resend countdown ----
    function stopCountdown() {
      if (countdownTimer) { clearInterval(countdownTimer); countdownTimer = null; }
    }
    function startCountdown() {
      stopCountdown();
      var left = RESEND_SECONDS;
      function tick() {
        if (countdownEl) {
          var m = Math.floor(left / 60), s = left % 60;
          countdownEl.textContent =
            (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s);
        }
        if (left <= 0) {
          stopCountdown();
          if (countdownEl) countdownEl.parentElement.style.display = 'none';
          if (resendBtn) resendBtn.hidden = false;
          return;
        }
        left--;
      }
      if (countdownEl && countdownEl.parentElement) countdownEl.parentElement.style.display = '';
      if (resendBtn) resendBtn.hidden = true;
      tick();
      countdownTimer = setInterval(tick, 1000);
    }

    function openVerifyDialog(email, msg, isError) {
      if (verifyEmailEl) verifyEmailEl.textContent = email || '';
      setVerifyMsg(msg || '', isError);
      showState('verify');
      startCountdown();
      startVerificationPolling();
    }

    // Live-poll Firebase so "I've verified my email" unlocks on its own the
    // moment the user clicks the link in another tab — no manual click needed.
    function startVerificationPolling() {
      if (pollTimer) return;
      pollTimer = setInterval(function () {
        SPAuth.ensureFirebase().then(function (firebase) {
          var user = firebase.auth().currentUser;
          if (!user) return;
          return user.reload().then(function () {
            if (user.emailVerified) {
              if (checkBtn) checkBtn.disabled = false;
              if (verifyFootEl) verifyFootEl.textContent = 'Verified — you can continue now.';
              return user.getIdToken(true);
            }
          });
        }).catch(function () {});
      }, 4000);
    }

    // ---- create account + send verification link ----
    createBtn.addEventListener('click', function () {
      setError('');
      var email = val('adminEmail');
      var password = pwInput.value;
      pwField.classList.remove('has-error');

      if (!email || !window.SPForms.EMAIL_RE.test(email)) {
        setError('Enter a valid work email above first.');
        return;
      }
      if (!password || password.length < 8) {
        pwField.classList.add('has-error');
        return;
      }

      createBtn.disabled = true;
      var createLabel = createBtn.innerHTML;
      createBtn.textContent = 'Creating account…';
      createBtn.setAttribute('aria-busy', 'true');

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
          // The account itself now exists (created or signed into above) —
          // a failure past this point is only about sending the
          // verification email, not account creation, so it gets its own
          // message and still opens the "Check your email" dialog (where
          // "Resend email" can retry) rather than the generic
          // account-creation failure below.
          return SPAuth.callFunction('requestEmailVerification', { method: 'POST' }).then(function () {
            openVerifyDialog(email, '');
          }).catch(function () {
            openVerifyDialog(email,
              "Your account was created, but we couldn't send the verification email. Use Resend below to try again.",
              true);
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
        createBtn.innerHTML = createLabel;
        createBtn.removeAttribute('aria-busy');
      });
    });

    resendBtn.addEventListener('click', function () {
      resendBtn.disabled = true;
      var label = resendBtn.textContent;
      resendBtn.textContent = 'Sending…';
      resendBtn.setAttribute('aria-busy', 'true');
      SPAuth.callFunction('requestEmailVerification', { method: 'POST' }).then(function () {
        setVerifyMsg('Verification link sent again to ' + val('adminEmail') + '.', false);
      }).catch(function () {
        // Best-effort — the endpoint rate-limits repeated sends; not worth a
        // hard error state here, the visitor can just try again shortly.
        setVerifyMsg('Could not resend just now. Please wait a moment and try again.', true);
      }).finally(function () {
        resendBtn.disabled = false;
        resendBtn.textContent = label;
        resendBtn.removeAttribute('aria-busy');
        startCountdown();
      });
    });

    if (changeEmailBtn) {
      changeEmailBtn.addEventListener('click', function () {
        // Return to the form so the visitor can correct the work email,
        // then create the account again with the corrected address.
        showState('create');
        setVerifyMsg('');
        var emailEl = byName('adminEmail');
        if (emailEl) { emailEl.focus(); emailEl.select && emailEl.select(); }
      });
    }
    if (verifyCloseBtn) {
      verifyCloseBtn.addEventListener('click', function () { showState('create'); });
    }
    if (verifyBackdrop) {
      verifyBackdrop.addEventListener('click', function () { showState('create'); });
    }

    checkBtn.addEventListener('click', function () {
      checkBtn.disabled = true;
      var label = checkBtn.innerHTML;
      checkBtn.textContent = 'Checking…';
      checkBtn.setAttribute('aria-busy', 'true');
      SPAuth.ensureFirebase().then(function (firebase) {
        var user = firebase.auth().currentUser;
        if (!user) return Promise.reject(new Error('not_signed_in'));
        return user.reload().then(function () {
          if (!user.emailVerified) {
            setVerifyMsg('Still not verified yet. Check your inbox (and spam folder), click the link, then try again.', true);
            checkBtn.disabled = false;
            return;
          }
          // See the matching comment in initSubmit() - force-refresh the ID
          // token now so the claim it carries is fresh by the time
          // submitSchoolApplication is called later, not just the
          // client-side emailVerified flag this markVerified() call gates
          // the UI on.
          return user.getIdToken(true).then(function () { markVerified(user.email); });
        });
      }).catch(function () {
        checkBtn.disabled = false;
      }).finally(function () {
        checkBtn.innerHTML = label;
        checkBtn.removeAttribute('aria-busy');
      });
    });

    // If a user already has a verified session (e.g. came back to this
    // page later), skip straight to the verified state.
    SPAuth.currentUser().then(function (user) {
      if (user && user.emailVerified && val('adminEmail') && user.email.toLowerCase() === val('adminEmail').toLowerCase()) {
        markVerified(user.email);
      }
    });

    // Baseline: nothing created yet.
    showState('create');
  }

  // ---- Step 6: real submit ----
  function buildBody() {
    var studentCount = Number(val('studentCount')) || 0;
    var tier = window.getTierForCount(studentCount);
    var plan = tier.plan || null;
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
          slug: window.SPSlug.sanitize(val('subdomain')),
        },
        location: {
          region: val('region'),
          district: val('district'),
          address: val('address'),
        },
        administrator: (function () {
          // A single-word name (e.g. "Victor") must not duplicate into both
          // firstName and lastName - split(' ').slice(1) already correctly
          // returns '' for lastName in that case; the previous `|| fullName`
          // fallback on lastName was wrong (it existed to guard firstName
          // against an empty/whitespace-only name, not to backfill lastName).
          var parts = val('adminName').trim().split(/\s+/);
          return {
            firstName: parts[0] || val('adminName'),
            lastName: parts.slice(1).join(' '),
            phone: val('adminPhone'),
            email: val('adminEmail'),
          };
        })(),
        academicCalendar: {
          schoolYear: val('schoolYear'),
          term: (function () {
            var checked = document.querySelector('input[name="term"]:checked');
            return checked ? checked.value : '';
          })(),
          termStart: val('termStart'),
          termEnd: val('termEnd'),
        },
        plan: plan,
        selectedModules: [],
        // Step 6 has a real accuracy/terms checkbox now — send what the
        // visitor actually confirmed, not a hardcoded true.
        termsAccepted: (function () {
          var box = document.getElementById('termsAccept');
          return !!(box && box.checked);
        })(),
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

      // Accuracy / terms acceptance is a hard gate — the button is already
      // disabled until the box is ticked, this just covers a programmatic click.
      var termsBox = document.getElementById('termsAccept');
      if (termsBox && !termsBox.checked) {
        var consent = document.getElementById('reviewConsent');
        if (consent) consent.classList.add('has-error');
        return;
      }

      // The backend requires both first and last name; the wizard only
      // collects one "Administrator name" field, so a single-word entry
      // (e.g. "Victor") needs to be caught here with a clear message rather
      // than reaching submitSchoolApplication and bouncing back as a
      // generic "invalid_application".
      if (val('adminName').trim().split(/\s+/).length < 2) {
        setError('Please enter the administrator\'s full name (first and last) in Step 2.');
        if (window.SPWizard) window.SPWizard.goToStep(2);
        return;
      }

      var built = buildBody();

      if (!built.plan) {
        // Enterprise/1501+ tier — no fixed price, cannot self-serve-submit.
        customNotice.style.display = 'block';
        return;
      }

      submitting = true;
      submitBtn.disabled = true;
      submitBtn.textContent = 'Submitting…';
      submitBtn.setAttribute('aria-busy', 'true');

      // Re-check verification live against Firebase Auth rather than
      // trusting the module-level `verified` flag set by initAccountGate -
      // a visitor who lands straight on this step (e.g. returning via the
      // verification email's ?verified=1 link with Step 6 restored from
      // localStorage) can reach here before that flag's own async
      // currentUser() check has resolved, which used to bounce them back
      // to Step 2 even though their email really was already verified.
      SPAuth.ensureFirebase().then(function (firebase) {
        var user = firebase.auth().currentUser;
        if (!user) return false;
        return user.reload().then(function () {
          if (!user.emailVerified) return false;
          // user.reload() refreshes the client-side emailVerified flag, but
          // the cached ID token's own email_verified claim doesn't update
          // until the token itself is force-refreshed - without this,
          // submitSchoolApplication's verifiedIdentity() (index.js) decodes
          // the stale token and 401s even though the UI now correctly shows
          // "verified". getIdToken(true) forces that refresh so the token
          // callFunction sends next actually carries the new claim.
          return user.getIdToken(true).then(function () { return true; });
        });
      }).catch(function () { return false; }).then(function (isVerified) {
        if (!isVerified) {
          submitting = false;
          submitBtn.disabled = false;
          submitBtn.textContent = 'Submit registration';
          submitBtn.removeAttribute('aria-busy');
          verifyNotice.style.display = 'block';
          // Send the visitor back to the account step rather than just
          // showing a message they might not connect to Step 2.
          if (window.SPWizard) window.SPWizard.goToStep(2);
          return;
        }

        return SPAuth.callFunction('submitSchoolApplication', { method: 'POST', body: built.body }).then(function (data) {
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
          submitBtn.removeAttribute('aria-busy');
        });
      });
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initRegionDistrictCascade();
    initAccountGate();
    initSubmit();
  });
})();
