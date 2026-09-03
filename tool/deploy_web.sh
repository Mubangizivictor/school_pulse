#!/usr/bin/env bash
#
# Builds and deploys School Pulse's web hosting correctly.
#
# firebase.json's hosting.public is build/web, and it serves TWO different
# things from that one directory:
#   - the root (/, /pricing, /register-school, ...) = the static marketing
#     site, whose source is web_marketing/ and is NOT built by Flutter at
#     all - those files must already exist under build/web/ before this
#     script runs (copy web_marketing/*  into build/web/ if they're missing
#     or out of date; this script does not do that copy for you, it only
#     protects what's already there).
#   - /app/**  = the actual Flutter SPA (welcome/login/every school-role
#     route), rewritten by firebase.json's "/app/**" -> "/app/index.html"
#     rule.
#
# A PLAIN `flutter build web` writes its own index.html at the OUTPUT ROOT,
# which is build/web/index.html by default - the exact same path the
# marketing homepage lives at. Running it without --output silently
# overwrites the live marketing homepage with Flutter's bootstrap shell.
# This happened for real on 2026-09-03 and had to be manually fixed before
# deploy. This script exists so that mistake can't happen again: it always
# builds into build/web/app (matching firebase.json's rewrite), verifies
# build/web/index.html still matches web_marketing/index.html afterward,
# and refuses to deploy if it doesn't.
#
# Usage:
#   tool/deploy_web.sh            # build + verify + deploy
#   tool/deploy_web.sh --no-deploy  # build + verify only, skip firebase deploy

set -euo pipefail
cd "$(dirname "$0")/.."

DEPLOY=1
if [[ "${1:-}" == "--no-deploy" ]]; then
  DEPLOY=0
fi

echo "==> flutter build web --release --base-href=/app/ --output=build/web/app"
flutter build web --release --base-href=/app/ --output=build/web/app

echo "==> Verifying build/web/index.html is still the marketing homepage, not Flutter's shell"
if [[ ! -f build/web/index.html ]]; then
  echo "FAIL: build/web/index.html is missing entirely." >&2
  echo "Copy web_marketing/*.html, web_marketing/css/, web_marketing/js/ into build/web/ first." >&2
  exit 1
fi
if grep -q "flutter_bootstrap.js" build/web/index.html; then
  echo "FAIL: build/web/index.html is Flutter's bootstrap shell, not the marketing homepage." >&2
  echo "This means something just overwrote it - restore it before deploying:" >&2
  echo "  cp web_marketing/index.html build/web/index.html" >&2
  exit 1
fi
if ! diff -q build/web/index.html web_marketing/index.html > /dev/null 2>&1; then
  echo "FAIL: build/web/index.html does not match web_marketing/index.html." >&2
  echo "The marketing site changed since build/web/ was last populated - copy the current" >&2
  echo "web_marketing/ files into build/web/ (index.html, other *.html, css/, js/) before deploying." >&2
  exit 1
fi

echo "==> Verifying build/web/app/index.html is the real Flutter shell"
if ! grep -q "flutter_bootstrap.js\|main.dart.js" build/web/app/index.html 2>/dev/null; then
  echo "FAIL: build/web/app/index.html doesn't look like a Flutter build output." >&2
  exit 1
fi

echo "==> Build verified: root serves the marketing site, /app serves the Flutter SPA."

if [[ "$DEPLOY" -eq 0 ]]; then
  echo "==> --no-deploy passed, stopping before firebase deploy."
  exit 0
fi

echo "==> firebase deploy --only hosting"
firebase deploy --only hosting
