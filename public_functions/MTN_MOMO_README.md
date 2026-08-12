# MTN Mobile Money Collections Integration

In-app automated subscription payment via MTN MoMo Collections API. Flutter never talks to MTN directly — every call goes through these `public_functions/` Cloud Functions.

## Architecture

```
Flutter (subscription_payment feature)
  -> initiateMtnPayment (onCall)   -> creates mtn_payments/{id}, calls MTN RequestToPay
  -> checkMtnPaymentStatus (onCall) -> polls MTN, settles subscription on SUCCESSFUL
```

Files:
- `mtn_config.js` — secrets + sandbox/production environment config (`getMtnConfig()`)
- `phone_utils.js` — Uganda MSISDN normalization/validation
- `mtn_client.js` — MTN HTTP calls, token caching, status mapping (`mapMtnStatus`)
- `mtn_momo.js` — the two callables, plus internal settlement logic (`checkAndSettle`)
- `payments.js` — exports a `__internal` bundle (`text`, `resolveSubscriber`, `schoolAdminEmail`, etc.) reused by `mtn_momo.js`; otherwise unchanged

## Required Firebase secrets

Set via Secret Manager, never in code or `.env`:

```
firebase functions:secrets:set MTN_MOMO_API_USER --project school-pulse-3d95b
firebase functions:secrets:set MTN_MOMO_API_KEY --project school-pulse-3d95b
firebase functions:secrets:set MTN_MOMO_SUBSCRIPTION_KEY --project school-pulse-3d95b
```

Non-secret config (see `.env.example`): `MTN_MOMO_TARGET_ENVIRONMENT`, `MTN_MOMO_BASE_URL`, `MTN_MOMO_SANDBOX_TEST_MSISDN`, `MTN_MOMO_SANDBOX_TEST_AMOUNT`.

## Sandbox setup

1. Set the three secrets above with sandbox API user/key/subscription key from a MoMo Developer Portal Collections product.
2. Leave `MTN_MOMO_TARGET_ENVIRONMENT` unset or `sandbox` (default).
3. Deploy: `firebase deploy --only functions:publicwebsite,firestore:rules,firestore:indexes`.

## How to test

- Unit tests: `cd public_functions && npm test` (covers phone normalization, status mapping, config branching, settlement math).
- Manual sandbox flow: sign in as a `schoolAdmin` on a school with a priced plan, open Subscription & Billing → "Pay with MTN Mobile Money", submit any Uganda-shaped number. In sandbox, MTN actually charges the fixed `MTN_MOMO_SANDBOX_TEST_MSISDN`, not the number entered — the UI shows a banner explaining this. Watch `mtn_payments/{id}` in the Firestore console move `CREATED → PENDING → SUCCESSFUL`.

## Status lifecycle

`CREATED → PENDING → SUCCESSFUL | FAILED | EXPIRED | CANCELLED` (never `UNKNOWN` at rest — that's a transient mapping fallback only). Only `SUCCESSFUL` triggers settlement. `202 Accepted` from MTN's RequestToPay means "accepted for processing," not paid — the payment stays `PENDING` until a subsequent status check confirms `SUCCESSFUL`.

Polling is client-driven: the Flutter cubit calls `checkMtnPaymentStatus` on a bounded backoff (5s/10s/15s/30s/60s), then stops and shows a "still processing" state. Each call also live-streams `mtn_payments/{id}` directly so a settlement lands in the UI immediately, without waiting for the next poll.

## Idempotency

- **Double-tap PAY**: `initiateMtnPayment` checks for an existing `CREATED`/`PENDING` payment for the same school before creating a new one (reuses it if <10 min old, otherwise marks it `EXPIRED` and starts fresh).
- **Repeated settlement**: `checkAndSettle(paymentId)` is safe to call any number of times — it short-circuits if `mtn_payments/{id}.status` is already `SUCCESSFUL`, so 20 status checks in a row settle the subscription exactly once.

## Inspecting failures

- `mtn_payments/{id}.failureReason` — safe, non-secret failure code (e.g. `mtn_status_expired`, `mtn_requesttopay_failed_400`).
- `super_admin_audit_logs` — `MTN_PAYMENT_CREATED` / `_SUBMITTED` / `_SUCCESSFUL` / `_FAILED` / `_STATUS_CHECKED`, `SUBSCRIPTION_ACTIVATED_FROM_PAYMENT`, each with `schoolId`/`paymentId`/`actorUserId`.
- Cloud Functions logs: structured `MTN_TOKEN_*` / `MTN_REQUEST_TO_PAY*` / `MTN_GET_STATUS*` log lines include `paymentId`, HTTP status, and duration only — never the Authorization header, Basic auth string, or bearer token.

## Production differences (not yet active)

Set `MTN_MOMO_TARGET_ENVIRONMENT=production_uganda` (or `mtnuganda`) and `MTN_MOMO_BASE_URL` to the real MTN Uganda endpoint once commercial onboarding is complete and production credentials are issued. This switches `getMtnConfig()` to `currency: 'UGX'`, drops the sandbox test MSISDN substitution (real numbers get charged), and removes the sandbox banner from the Flutter UI. No code changes are required elsewhere — every call site reads through `getMtnConfig()`.
