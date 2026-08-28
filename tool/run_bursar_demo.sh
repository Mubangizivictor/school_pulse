#!/usr/bin/env bash
#
# Runs the full Bursar/Finance demo against the local Firebase Emulator Suite.
#
#   1. starts the Firestore + Auth + Storage emulators (firebase.json)
#   2. seeds every Bursar screen  (functions/scripts/seed_bursar_demo.js)
#   3. launches the Flutter app pointed at the emulator
#
# Demo login:  bursar@schoolpulse.demo / Test@123
#
# All demo data is namespaced under the "school-pulse-academy" tenant and
# marked { demoSeed: 'seed_bursar_demo' } - wipe it by restarting the
# emulator (it keeps nothing) or deleting that school.
#
# Usage:
#   tool/run_bursar_demo.sh            # emulator + seed + run on default device
#   tool/run_bursar_demo.sh -d <id>   # pick a device
set -euo pipefail

cd "$(dirname "$0")/.."

DEVICE_ARGS=()
if [[ "${1:-}" == "-d" && -n "${2:-}" ]]; then
  DEVICE_ARGS=(-d "$2")
fi

# firebase-tools needs a JDK 21+. Homebrew keeps versioned JDKs keg-only, so
# point JAVA_HOME at openjdk@21 if it's installed and the default java is old.
if ! java -version 2>&1 | grep -qE '"(2[1-9]|[3-9][0-9])'; then
  for jdk in /opt/homebrew/opt/openjdk@21 /opt/homebrew/opt/openjdk \
    /usr/local/opt/openjdk@21 /opt/homebrew/Cellar/openjdk@21/*; do
    if [[ -x "$jdk/bin/java" || -x "$jdk/libexec/openjdk.jdk/Contents/Home/bin/java" ]]; then
      [[ -d "$jdk/libexec/openjdk.jdk/Contents/Home" ]] \
        && export JAVA_HOME="$jdk/libexec/openjdk.jdk/Contents/Home" \
        || export JAVA_HOME="$jdk"
      export PATH="$JAVA_HOME/bin:$PATH"
      break
    fi
  done
  echo "==> Using JAVA_HOME=$JAVA_HOME"
fi

export GCLOUD_PROJECT="school-pulse-3d95b"
export FIRESTORE_EMULATOR_HOST="localhost:8080"
export FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"
export FIREBASE_STORAGE_EMULATOR_HOST="localhost:9199"

echo "==> Starting Firebase emulators (Firestore/Auth/Storage)…"
# functions is required: the staff-login gate calls assertNotPlatformOwner.
firebase emulators:start --only firestore,auth,storage,functions --project "$GCLOUD_PROJECT" &
EMU_PID=$!
trap 'echo "==> Stopping emulators"; kill $EMU_PID 2>/dev/null || true' EXIT

# Wait for Firestore emulator to accept connections.
echo "==> Waiting for Firestore emulator on 8080…"
for _ in $(seq 1 60); do
  if curl -s "http://localhost:8080/" >/dev/null 2>&1; then break; fi
  sleep 1
done

echo "==> Seeding Bursar demo data…"
node functions/scripts/seed_bursar_demo.js

echo "==> Launching the app against the emulator…"
flutter run "${DEVICE_ARGS[@]}" --dart-define=USE_FIREBASE_EMULATOR=true
