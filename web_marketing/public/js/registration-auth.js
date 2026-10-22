// Shared Firebase Auth + backend-call helpers for the post-application
// pages (application-status.html, payment.html). These are the only two
// marketing pages that need a signed-in Firebase user: both
// getSchoolApplicationStatus and getManualPaymentContext/submitManualPayment
// require a verified-email Bearer ID token (see public_functions/payments.js
// verifiedIdentity()). register-school.html is not wired to Firebase Auth
// yet (separate follow-up) so this file is deliberately self-contained
// rather than assuming a shared sign-in session already exists.
(function () {
  var FIREBASE_SDK_VERSION = '10.14.1';
  var FIREBASE_CONFIG = {
    apiKey: 'AIzaSyCvVUyX1_3tuxHlhS3rdCruV08_FISvIG8',
    authDomain: 'school-pulse-3d95b.firebaseapp.com',
    projectId: 'school-pulse-3d95b',
    storageBucket: 'school-pulse-3d95b.firebasestorage.app',
    messagingSenderId: '925585407650',
    appId: '1:925585407650:web:73c0b063dc0398cf9461fb',
  };
  var FUNCTIONS_BASE = 'https://europe-west1-school-pulse-3d95b.cloudfunctions.net';

  // Served from localhost (npm run dev / next start) -> talk to the local
  // Firebase Emulator Suite instead of production, so testing the register
  // flow never creates real accounts or applications. Start the emulators
  // first: firebase emulators:start (ports from firebase.json).
  var USE_EMULATOR = /^(localhost|127\.0\.0\.1)$/.test(window.location.hostname);
  if (USE_EMULATOR) {
    FUNCTIONS_BASE = 'http://127.0.0.1:5001/' + FIREBASE_CONFIG.projectId + '/europe-west1';
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src;
      s.onload = resolve;
      s.onerror = function () { reject(new Error('Failed to load ' + src)); };
      document.head.appendChild(s);
    });
  }

  var sdkReady = null;
  function ensureFirebase() {
    if (sdkReady) return sdkReady;
    sdkReady = loadScript('https://www.gstatic.com/firebasejs/' + FIREBASE_SDK_VERSION + '/firebase-app-compat.js')
      .then(function () { return loadScript('https://www.gstatic.com/firebasejs/' + FIREBASE_SDK_VERSION + '/firebase-auth-compat.js'); })
      .then(function () { return loadScript('https://www.gstatic.com/firebasejs/' + FIREBASE_SDK_VERSION + '/firebase-storage-compat.js'); })
      .then(function () {
        if (!window.firebase.apps.length) {
          window.firebase.initializeApp(FIREBASE_CONFIG);
          if (USE_EMULATOR) {
            window.firebase.auth().useEmulator('http://127.0.0.1:9099');
            window.firebase.storage().useEmulator('127.0.0.1', 9199);
            console.info('School Pulse: using the local Firebase emulators');
          }
        }
        return window.firebase;
      });
    return sdkReady;
  }

  // Resolves with the signed-in firebase.User once auth state settles (null
  // if signed out). Used on page load to decide whether to show the
  // sign-in gate or go straight to fetching status/context.
  function currentUser() {
    return ensureFirebase().then(function (firebase) {
      return new Promise(function (resolve) {
        var unsub = firebase.auth().onAuthStateChanged(function (user) {
          unsub();
          resolve(user);
        });
      });
    });
  }

  function signIn(email, password) {
    return ensureFirebase().then(function (firebase) {
      return firebase.auth().signInWithEmailAndPassword(email, password);
    });
  }

  function signOut() {
    return ensureFirebase().then(function (firebase) { return firebase.auth().signOut(); });
  }

  // Calls one of the onRequest HTTPS functions in public_functions with the
  // signed-in user's ID token as a Bearer header, matching verifiedIdentity()
  // in public_functions/payments.js exactly (email must be verified there).
  function callFunction(name, options) {
    options = options || {};
    return ensureFirebase().then(function (firebase) {
      var user = firebase.auth().currentUser;
      if (!user) return Promise.reject({ error: 'not_signed_in', message: 'Please sign in first.' });
      return user.getIdToken().then(function (token) {
        return fetch(FUNCTIONS_BASE + '/' + name, {
          method: options.method || 'GET',
          headers: Object.assign(
            { Authorization: 'Bearer ' + token },
            options.body ? { 'Content-Type': 'application/json' } : {},
          ),
          body: options.body ? JSON.stringify(options.body) : undefined,
        }).then(function (res) {
          return res.json().catch(function () { return {}; }).then(function (data) {
            if (!res.ok) return Promise.reject(Object.assign({ status: res.status }, data));
            return data;
          });
        });
      });
    });
  }

  // Uploads a File to Storage at payment_proofs/{uid}/{fileName}, the exact
  // prefix submitManualPayment validates (public_functions/payments.js:
  // "const expectedPrefix = `payment_proofs/${identity.uid}/`"). Returns the
  // storage path string to send as proofStoragePath.
  function uploadPaymentProof(file, onProgress) {
    return ensureFirebase().then(function (firebase) {
      var user = firebase.auth().currentUser;
      if (!user) return Promise.reject({ error: 'not_signed_in', message: 'Please sign in first.' });
      var safeName = String(file.name || 'proof').replace(/[^A-Za-z0-9_.-]/g, '_').slice(-100);
      var path = 'payment_proofs/' + user.uid + '/' + Date.now() + '_' + safeName;
      var ref = firebase.storage().ref().child(path);
      var task = ref.put(file, { contentType: file.type });
      return new Promise(function (resolve, reject) {
        task.on('state_changed', function (snap) {
          if (onProgress) onProgress(snap.bytesTransferred / snap.totalBytes);
        }, reject, function () {
          resolve(path);
        });
      });
    });
  }

  window.SPAuth = {
    ensureFirebase: ensureFirebase,
    currentUser: currentUser,
    signIn: signIn,
    signOut: signOut,
    callFunction: callFunction,
    uploadPaymentProof: uploadPaymentProof,
  };
})();
