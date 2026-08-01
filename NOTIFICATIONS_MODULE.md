# Notifications Module — Status

Last updated: 1 August 2026

## What this is

The notification module was rebuilt behind the existing UI. **No screen layout,
colour, or component was changed.** The screens you built are intact; what
changed is that they now read real data and their buttons do something.

---

## Verification status

| Check | Result |
|---|---|
| `flutter analyze` | **0 errors** (was 3 pre-existing errors at start) |
| Notification tests | **98 passing** (263 in the full suite) |
| iOS build (iPhone 16 Pro Max) | **Succeeds** |
| App launches and runs | **Yes** |
| Dead buttons in notification screens | **0** (was 8) |
| Real push delivery (fg / bg / terminated) | **BLOCKED** — see below |

### Not verified — and currently blocked

**Push delivery cannot be tested on this machine.** Two independent blockers:

1. **A simulator has no APNs token**, so it can never receive push.
2. **The physical iPhone build fails at code signing.** Verified 1 Aug 2026:

   > Cannot create a iOS App Development provisioning profile for
   > `com.example.schoolPulse`. Personal development teams, including
   > "VICTOR MUBANGIZI", do not support the Push Notifications capability.

   A free/personal Apple team **cannot use the Push Notifications
   entitlement at all**. This needs a paid Apple Developer Program
   membership. The bundle id is also still the placeholder
   `com.example.schoolPulse`.

**Android has no such restriction** — FCM on a real Android device needs no
paid membership, so that is the cheapest way to prove delivery today.

Once unblocked:

1. `firebase deploy --only functions`
2. `firebase deploy --only firestore:rules,firestore:indexes`
3. Real device → `/staff/notifications/test` → "Send real push to my devices"
4. Repeat with the app **open**, **backgrounded**, and **fully closed**

Until then, treat push as built-but-unproven.

**Firestore rules were not emulator-validated.** They are brace-balanced and
syntactically checked, but `firebase emulators:exec` requires JDK 21 and this
machine has an older JDK. Validate before relying on them.

---

## Architecture

```
lib/features/notifications/
  domain/        entities, category catalog, delivery policy, failures, send service
  data/          Isar offline cache, Firestore datasource, mappers, image cache, seed
  presentation/  bloc + your existing screens (wired)
  push/          FCM payloads, token management, fg/bg/terminated handlers, badges
  local/         notification channels, presenter
  routing/       deep-link router + authorization
  testing/       delivery test service, seed runner
  notification_coordinator.dart   — single start/stop entry point
```

### Key decisions

**One Firestore document per recipient**, not one shared document with a
recipients array. This makes per-user read state a single-field write instead
of an array mutation contended by every recipient, and lets a security rule
compare `recipientUserId` to the caller directly.

**Read / opened / delivered / acknowledged are separate timestamps.** They
never collapse into one flag.

**Deep links are never followed verbatim.** A push payload is attacker-
influenced input. The router resolves destinations from the *typed event kind*
(set by trusted server code), then checks: authenticated → same tenant →
addressed to this user → not expired → permitted → route buildable → target
still exists. Anything without an explicit permission rule is **denied**.

**Fan-out is server-side.** The client writes a `notification_requests`
document; a Cloud Function resolves the audience and writes recipient
documents with the Admin SDK. Clients cannot create notification documents at
all — that closes the hole where a client could forge a notification appearing
to come from the school office.

**Pushes are data-only** so the client applies quiet hours, category mutes and
lock-screen redaction itself. An OS-rendered notification block would bypass
all of it.

**Offline-first.** Reads serve cache then refresh; writes apply locally and
queue. Marking read never waits on the network and is never lost offline.

---

## Cost controls

- Badge counts come from the local cache, debounced — not a server aggregation
  query per read.
- `markAllAsRead` only touches rows that are actually unread.
- Chat pings are **transient**: they clear when the conversation opens, rather
  than accumulating one permanent document per message.
- Token publishing is skipped when the token is already published (previously
  one write per cold start per user).
- Dead FCM tokens are pruned so later sends stop retrying them.
- Search debounces at 300 ms.
- Images are cached by URL hash, so one banner shared by many notifications is
  stored once.

---

## Safety rules that are enforced

- Emergency, medical, attendance, gate and security categories **cannot be
  muted** by a user, and override quiet hours.
- Sensitive categories (medical, finance, discipline, counselling) are **never
  shown in full on a lock screen**, regardless of user or school setting.
- A parent can only reach **their own children's** records.
- An **unacknowledged alert cannot be deleted** — enforced in the UI, the
  repository, and the Firestore rules.
- Automated events are **never attributed to a human sender**.
- Signing out **revokes the device token**; if that fails offline it is queued,
  so a signed-out user cannot keep receiving another tenant's alerts.

---

## Development seed data

`/staff/notifications/test` → "Seed notifications" writes 24 sample
notifications covering every UI state (read/unread/pinned/archived, all four
priorities, acknowledgement outstanding and satisfied, delivery failure,
scheduled, broken image, expired deep-link target, transient chat ping).

Seed data is **local to the device only** — never written to Firestore, never
pushed, and refused entirely in release builds.

---

## Known gaps

These are the honest remainder. Everything else in the original spec is built.

- **Digest delivery.** The digest is composed and tested
  (`NotificationDigestBuilder`), and the preference toggles exist, but nothing
  yet *schedules* a daily/weekly send. It needs a Cloud Function on a timer.
- **Email / SMS sending.** Copies are queued into `email_queue` / `sms_queue`
  for recipients who opted in, but `processSmsQueue` is still the project's
  pre-existing placeholder and there is no email worker. Plugging in a provider
  is the remaining step.
- **Template editing UI.** The 17 built-in templates render and are covered by
  tests; a school can override them in Firestore, but there is no screen for
  authoring overrides.
- **Web / Windows / macOS push** — untested. Channels and the presenter are
  Android/iOS-shaped.
- **iOS push entitlement** — blocked on a paid Apple Developer membership (see
  Verification status).

## Unrelated issues found

- `boarding_attendance` needed a composite index on `type` + `date`; it was
  throwing `failed-precondition` and crashing that screen. **Index added** to
  `firestore.indexes.json` — deploy to take effect.
- The nurse dashboard was rewritten (header, quick actions) and its tests still
  asserted the previous copy. **Tests updated** to match the new UI.
