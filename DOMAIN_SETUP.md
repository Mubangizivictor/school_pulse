# School Pulse portal domains

School Pulse uses one Firebase Hosting deployment for the platform and every school portal. A tenant is selected at runtime from a minimal public `portal_domains/{hostname}` document; private `schools/{schoolId}` data is never publicly readable.

## DNS and Hosting

Attach `schoolpulse.ug` and `www.schoolpulse.ug` to the Firebase Hosting site that deploys `build/web`, following Firebase Console ownership and A/AAAA instructions. Create `*.schoolpulse.ug CNAME <Firebase Hosting target supplied by Firebase>`, and enable Firebase Hosting wildcard SSL for that site. If wildcard certificates are unavailable on the selected Hosting plan, terminate the wildcard at a managed HTTPS edge in front of the same Hosting origin. Keep the existing `** -> /index.html` rewrite; do not deploy one app per school.

## Custom domain process

The platform owner calls `createSchoolPortal`, which atomically reserves a slug, provisions the initial school admin membership, creates audit records, and writes the public hostname projection. A school admin calls `requestCustomPortalDomain` and receives this instruction:

```
portal.greenhillschool.ac.ug CNAME ghs.googlehosted.com
```

The platform owner attaches/verifies that exact hostname in Firebase Hosting for TLS, then calls `verifyAndActivateCustomPortalDomain`. The function verifies the CNAME, activates the mapping, and audits it. School Pulse never changes school DNS.

## Local, rollout, rollback

For a tenant preview, use `flutter run -d chrome --dart-define=PORTAL_HOST=greenhill.schoolpulse.ug` only in debug/profile builds, with an active emulator `portal_domains` document. Deploy rules and Functions before the web bundle, verify root/www/wildcard TLS, then pilot one school. To roll back, remove the hostname mapping with the Admin SDK and set `domainStatus` to `suspended`; the app displays the neutral not-found page.
