// Shared origin allowlist for every public onRequest function's cors()
// check. schoolpulseapp.com is the production custom domain, but visitors
// (and this codebase's own testing) also legitimately reach the same site
// via Firebase's default hosting domains - both serve the identical
// build/web output, so a request from either is exactly as trustworthy as
// one from the custom domain. Missing these caused a real bug: every
// onRequest endpoint silently rejected calls made from
// https://school-pulse-3d95b.firebaseapp.com/web.app, surfacing to
// visitors as a generic "Could not create your account" error even when
// the actual failure was just this CORS check.
const ALLOWED_ORIGINS = new Set([
  'https://schoolpulseapp.com',
  'https://school-pulse-3d95b.firebaseapp.com',
  'https://school-pulse-3d95b.web.app',
  'http://localhost:4321',
]);

// Local dev servers (Next.js site on :3000, Flutter web on any port) are only
// trusted when these functions run inside the Firebase emulator - never in a
// deployed function.
const LOCAL_ORIGIN_RE = /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

function isAllowedOrigin(origin) {
  if (ALLOWED_ORIGINS.has(origin)) return true;
  return process.env.FUNCTIONS_EMULATOR === 'true' && LOCAL_ORIGIN_RE.test(String(origin || ''));
}

module.exports = { ALLOWED_ORIGINS, isAllowedOrigin };
