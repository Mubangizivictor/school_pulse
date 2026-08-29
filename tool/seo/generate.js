#!/usr/bin/env node
/**
 * Generates the School Pulse public marketing site into build/web/.
 *
 * Run AFTER `flutter build web` (which populates build/web/ with the app),
 * and BEFORE `firebase deploy --only hosting`. It writes:
 *
 *   build/web/<slug>/index.html   one static page per marketing route
 *   build/web/index.html          left as the Flutter app entry (only its
 *                                 <head> is rewritten — see patchAppIndex)
 *   build/web/robots.txt
 *   build/web/sitemap.xml         sitemap index
 *   build/web/sitemap-marketing.xml
 *   build/web/assets-marketing/*  shared css + og image
 *
 * It never touches Flutter's JS, wasm, or asset bundles.
 */
'use strict';

const fs = require('fs');
const path = require('path');
const cp = require('child_process');

const {
  CANONICAL_HOST,
  CONTACT,
  OG_IMAGE,
  PAGES,
  APP_DISALLOW,
} = require('./site.config');
const { CONTENT, HOME_FAQ } = require('./content');

const OUT = path.resolve(__dirname, '../../build/web');
const MARKETING_ASSET_SRC = path.resolve(__dirname, '../../web_marketing/assets');

function gitLastModified(files) {
  try {
    const out = cp
      .execSync(`git log -1 --format=%cI -- ${files.map(f => `'${f}'`).join(' ')}`, {
        cwd: path.resolve(__dirname, '../..'),
      })
      .toString()
      .trim();
    return out || new Date().toISOString();
  } catch (_) {
    return new Date().toISOString();
  }
}

const LASTMOD = gitLastModified([
  'tool/seo/site.config.js',
  'tool/seo/content.js',
  'tool/seo/generate.js',
]).slice(0, 10);

const esc = s =>
  String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

// ---------------------------------------------------------------------------
// JSON-LD
// ---------------------------------------------------------------------------
function organizationLd() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: CONTACT.company,
    url: `${CANONICAL_HOST}/`,
    logo: `${CANONICAL_HOST}/assets-marketing/logo.png`,
    slogan: CONTACT.tagline,
    email: CONTACT.email,
    telephone: CONTACT.phoneTel,
    areaServed: CONTACT.country,
    contactPoint: [
      {
        '@type': 'ContactPoint',
        contactType: 'sales',
        email: CONTACT.email,
        telephone: CONTACT.phoneTel,
        areaServed: 'UG',
        availableLanguage: ['en'],
      },
    ],
  };
}

function websiteLd() {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: CONTACT.company,
    url: `${CANONICAL_HOST}/`,
    inLanguage: 'en',
    publisher: { '@type': 'Organization', name: CONTACT.company },
  };
}

function softwareApplicationLd() {
  return {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: CONTACT.company,
    applicationCategory: 'BusinessApplication',
    applicationSubCategory: 'School Management Software',
    operatingSystem: 'Web, Android, iOS',
    url: `${CANONICAL_HOST}/`,
    description:
      'All-in-one school management platform for enrolment, attendance, ' +
      'fees, report cards, communication, transport, boarding and health.',
    offers: {
      '@type': 'Offer',
      // No public price is published; availability only.
      availability: 'https://schema.org/InStock',
      priceCurrency: 'UGX',
      price: '0',
      description: 'Contact School Pulse for a demo and pricing.',
    },
    publisher: { '@type': 'Organization', name: CONTACT.company },
  };
}

function breadcrumbLd(page) {
  const items = [
    { name: 'School Pulse', item: `${CANONICAL_HOST}/school-management-software-uganda` },
  ];
  if (page.path !== '/school-management-software-uganda') {
    items.push({
      name: page.h1 || page.title,
      item: `${CANONICAL_HOST}${page.path}`,
    });
  }
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((it, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: it.name,
      item: it.item,
    })),
  };
}

function faqLd() {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: HOME_FAQ.map(f => ({
      '@type': 'Question',
      name: f.q,
      acceptedAnswer: { '@type': 'Answer', text: f.a },
    })),
  };
}

// The primary indexable landing page carries the site-wide entity graph
// (Organization / WebSite / SoftwareApplication) and the product FAQ, since
// "/" itself is the Flutter app and is not in the marketing set.
const PRIMARY_LANDING = '/school-management-software-uganda';

function ldFor(page) {
  const blocks = [breadcrumbLd(page)];
  if (page.path === PRIMARY_LANDING) {
    blocks.unshift(organizationLd(), websiteLd(), softwareApplicationLd(), faqLd());
  }
  return blocks
    .map(
      b =>
        `<script type="application/ld+json">${JSON.stringify(b)}</script>`,
    )
    .join('\n  ');
}

// ---------------------------------------------------------------------------
// HTML template
// ---------------------------------------------------------------------------
const NAV = [
  ['/school-management-software-uganda', 'For Uganda'],
  ['/parent-portal', 'Parent portal'],
  ['/fees-and-payments', 'Fees'],
  ['/academics-and-report-cards', 'Report cards'],
  ['/school-websites', 'School websites'],
  ['/request-demo', 'Request a demo'],
];

const FOOTER_LINKS = [
  ['/school-management-software-uganda', 'School management software in Uganda'],
  ['/student-information-and-enrolment', 'Student information & enrolment'],
  ['/attendance', 'Attendance'],
  ['/school-communication', 'School communication'],
  ['/transport-and-boarding', 'Transport & boarding'],
  ['/health-and-welfare', 'Health & welfare'],
  ['/about', 'About'],
  ['/contact', 'Contact'],
  ['/privacy-policy', 'Privacy Policy'],
  ['/terms-of-service', 'Terms of Service'],
];

function render(page) {
  const canonical = `${CANONICAL_HOST}${page.path}`;
  const body = CONTENT[page.slug]();
  const year = new Date().getFullYear();

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${esc(page.title)}</title>
  <meta name="description" content="${esc(page.description)}">
  <link rel="canonical" href="${canonical}">
  <meta name="robots" content="index, follow, max-image-preview:large">
  <meta name="theme-color" content="#0B5FFF">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="${esc(CONTACT.company)}">
  <meta property="og:title" content="${esc(page.title)}">
  <meta property="og:description" content="${esc(page.description)}">
  <meta property="og:url" content="${canonical}">
  <meta property="og:image" content="${OG_IMAGE}">
  <meta property="og:locale" content="en_UG">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${esc(page.title)}">
  <meta name="twitter:description" content="${esc(page.description)}">
  <meta name="twitter:image" content="${OG_IMAGE}">
  <link rel="icon" type="image/png" href="/favicon.png">
  <link rel="apple-touch-icon" href="/icons/Icon-192.png">
  <link rel="manifest" href="/manifest.json">
  <link rel="stylesheet" href="/assets-marketing/site.css">
  ${ldFor(page)}
</head>
<body>
  <a class="skip-link" href="#main">Skip to content</a>
  <header class="site-header">
    <div class="wrap">
      <a class="brand" href="/"><img src="/assets-marketing/logo.png" width="130" height="26" alt="School Pulse"></a>
      <nav aria-label="Primary">
        <ul>
          ${NAV.map(([h, t]) => `<li><a href="${h}">${esc(t)}</a></li>`).join('\n          ')}
        </ul>
      </nav>
      <a class="btn btn-primary header-cta" href="/request-demo">Request a demo</a>
    </div>
  </header>
  <main id="main" class="wrap">
    ${body}
  </main>
  <footer class="site-footer">
    <div class="wrap">
      <p class="foot-brand"><strong>${esc(CONTACT.company)}</strong> — ${esc(CONTACT.tagline)}</p>
      <ul class="foot-links">
        ${FOOTER_LINKS.map(([h, t]) => `<li><a href="${h}">${esc(t)}</a></li>`).join('\n        ')}
      </ul>
      <p class="foot-contact">
        <a href="mailto:${CONTACT.email}">${esc(CONTACT.email)}</a> ·
        <a href="https://wa.me/${CONTACT.whatsapp}" rel="nofollow noopener" target="_blank">WhatsApp ${esc(CONTACT.phoneDisplay)}</a>
      </p>
      <p class="foot-fine">© ${year} ${esc(CONTACT.company)}. Based in ${esc(CONTACT.country)}.</p>
    </div>
  </footer>
</body>
</html>
`;
}

// ---------------------------------------------------------------------------
// robots.txt + sitemaps
// ---------------------------------------------------------------------------
function robotsTxt() {
  // Kept deliberately permissive at the top (User-agent: * / Allow: /) so no
  // crawler is blocked from reaching an authenticated route far enough to
  // READ its `noindex` meta tag — robots.txt is not used here as the privacy
  // boundary (auth is). The Disallow lines below only steer crawl budget
  // away from app-only surfaces that carry no marketing value.
  const lines = [
    '# School Pulse — https://schoolpulseapp.com',
    'User-agent: *',
    'Allow: /',
    '',
  ];
  for (const d of APP_DISALLOW) lines.push(`Disallow: ${d}`);
  lines.push('');
  lines.push('# Flutter engine internals — no SEO value');
  lines.push('Disallow: /flutter_bootstrap.js');
  lines.push('Disallow: /flutter_service_worker.js');
  lines.push('Disallow: /canvaskit/');
  lines.push('');
  lines.push(`Sitemap: ${CANONICAL_HOST}/sitemap.xml`);
  lines.push('');
  return lines.join('\n');
}

function urlEntry(loc, lastmod, changefreq, priority) {
  return (
    '  <url>\n' +
    `    <loc>${loc}</loc>\n` +
    (lastmod ? `    <lastmod>${lastmod}</lastmod>\n` : '') +
    (changefreq ? `    <changefreq>${changefreq}</changefreq>\n` : '') +
    (priority ? `    <priority>${priority}</priority>\n` : '') +
    '  </url>'
  );
}

function marketingUrlset() {
  const urls = PAGES.map(p =>
    urlEntry(
      `${CANONICAL_HOST}${p.path}`,
      LASTMOD,
      p.changefreq || 'monthly',
      p.priority || '0.5',
    ),
  ).join('\n');
  return (
    '<?xml version="1.0" encoding="UTF-8"?>\n' +
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' +
    urls +
    '\n</urlset>\n'
  );
}

function sitemapIndex() {
  // sitemap.xml is a sitemap INDEX. Only sitemap-marketing.xml is listed
  // today. sitemap-school-sites.xml and sitemap-blog.xml are intentionally
  // NOT listed until there is real opted-in public content for them — an
  // empty sitemap is a crawl liability. Add them here when generate.js
  // starts producing them.
  const children = [
    { loc: `${CANONICAL_HOST}/sitemap-marketing.xml`, lastmod: LASTMOD },
  ];
  return (
    '<?xml version="1.0" encoding="UTF-8"?>\n' +
    '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' +
    children
      .map(
        c =>
          `  <sitemap>\n    <loc>${c.loc}</loc>\n    <lastmod>${c.lastmod}</lastmod>\n  </sitemap>`,
      )
      .join('\n') +
    '\n</sitemapindex>\n'
  );
}

// ---------------------------------------------------------------------------
// Verify the built Flutter index.html carries real School Pulse metadata.
// The real fix lives in web/index.html (source), so `flutter build web`
// already produces a correct build/web/index.html. This is a guard: if the
// Flutter placeholder ever comes back, the build fails loudly instead of
// silently redeploying "A new Flutter project".
// ---------------------------------------------------------------------------
function verifyAppIndex() {
  const file = path.join(OUT, 'index.html');
  if (!fs.existsSync(file)) {
    throw new Error(`missing ${file} — run flutter build web first`);
  }
  const html = fs.readFileSync(file, 'utf8');
  const problems = [];
  if (html.includes('A new Flutter project')) problems.push('placeholder description');
  if (/<title>\s*school_pulse\s*<\/title>/.test(html)) problems.push('placeholder <title>');
  if (!html.includes('<link rel="canonical"')) problems.push('missing canonical');
  if (!html.includes('og:title')) problems.push('missing Open Graph');
  if (problems.length) {
    throw new Error(
      `build/web/index.html not SEO-ready: ${problems.join(', ')}. ` +
        'Fix web/index.html and rebuild.',
    );
  }
  return file;
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
function main() {
  if (!fs.existsSync(OUT)) {
    console.error(`✗ ${OUT} not found. Run: flutter build web --release`);
    process.exit(1);
  }

  // shared assets
  const assetOut = path.join(OUT, 'assets-marketing');
  fs.mkdirSync(assetOut, { recursive: true });
  for (const f of fs.readdirSync(MARKETING_ASSET_SRC)) {
    fs.copyFileSync(path.join(MARKETING_ASSET_SRC, f), path.join(assetOut, f));
  }

  let written = 0;
  for (const page of PAGES) {
    // Every marketing page is a directory with an index.html, so Firebase
    // Hosting `cleanUrls` serves it at the bare path and 301s the
    // /path/index.html form back to /path (no duplicate indexable URL).
    const dir = path.join(OUT, page.path.replace(/^\//, ''));
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, 'index.html'), render(page));
    written++;
  }

  fs.writeFileSync(path.join(OUT, 'robots.txt'), robotsTxt());
  fs.writeFileSync(path.join(OUT, 'sitemap-marketing.xml'), marketingUrlset());
  fs.writeFileSync(path.join(OUT, 'sitemap.xml'), sitemapIndex());

  const appIndex = verifyAppIndex();

  console.log(`✓ ${written} marketing pages`);
  console.log(`✓ robots.txt, sitemap.xml (index), sitemap-marketing.xml (${PAGES.length} URLs)`);
  console.log(`✓ verified ${path.relative(process.cwd(), appIndex)} SEO metadata`);
  console.log(`  canonical host: ${CANONICAL_HOST}`);
  console.log(`  lastmod: ${LASTMOD}`);
}

main();
