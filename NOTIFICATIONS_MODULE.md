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
| Notification tests | **69 passing** |
| iOS build (iPhone 16 Pro Max) | **Succeeds** |
| App launches and runs | **Yes** |
| Dead buttons in notification screens | **0** (was 8) |
| Real push delivery (fg / bg / terminated) | **NOT VERIFIED** — see below |

### Not verified

**Push delivery has never been tested end to end.** A simulator has no APNs
token, so it cannot receive push at all. This requires:

1. `firebase deploy --only functions`
2. `firebase deploy --only firestore:rules,firestore:indexes`
3. A physical device
4. Open `/staff/notifications/test` → "Send real push to my devices"
5. Repeat with the app **open**, **backgrounded**, and **fully closed**

Until that is done, treat push as built-but-unproven.

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

These are **not built**, and are the honest remainder of the original spec:

- **Notification templates** with placeholder substitution (`templates/`
  directories are empty).
- **Digests** — the preference toggle exists and the policy batches low-priority
  notifications, but no digest is actually composed or sent.
- **Email / SMS channel copies** — preference toggles exist; no delivery path.
- **Per-class audience picking** in the compose screen — "Specific Class" falls
  back to staff rather than silently broadcasting school-wide.
- **School admin notification settings screen** — the policy model and rules
  exist and are read, but there is no UI to edit them.
- **Web / Windows / macOS push** — untested; channels and presenter are
  Android/iOS-shaped.

## Unrelated issue found

`boarding_attendance` throws an unhandled `failed-precondition` — it needs a
composite index on `type` + `date`. This is in the matron/patron module, not
notifications. Not fixed.
