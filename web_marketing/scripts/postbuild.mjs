// The old static site had no 404 page (Firebase served its default);
// drop the ones Next.js generates so hosting behaves exactly as before.
import fs from 'node:fs';
for (const f of ['out/404.html', 'out/404', 'out/_not-found.html', 'out/_not-found']) {
  fs.rmSync(f, { recursive: true, force: true });
}
