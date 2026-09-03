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

function isAllowedOrigin(origin) {
  return ALLOWED_ORIGINS.has(origin);
}

module.exports = { ALLOWED_ORIGINS, isAllowedOrigin };
