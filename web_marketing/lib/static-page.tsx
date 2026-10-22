import fs from 'node:fs';
import path from 'node:path';
import type { Metadata } from 'next';
import { siteMetadata } from './root-head';

// The site's pages live, unchanged, as the original hand-written HTML in
// pages-html/. At build time each one is split into its <title>, meta
// description, page-level <head> <style> block and <body> markup, and
// pre-rendered as static HTML. The markup and its <script> tags are
// emitted verbatim, so the browser parses and runs the original vanilla
// JS (nav.js, wizard.js, ...) exactly as it did before the Next.js move.

const PAGES_DIR = path.join(process.cwd(), 'pages-html');

type ParsedPage = {
  title: string;
  description: string;
  headStyle: string;
  body: string;
};

function decodeEntities(s: string): string {
  return s
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&amp;/g, '&');
}

function readPage(slug: string): ParsedPage {
  const html = fs.readFileSync(path.join(PAGES_DIR, `${slug}.html`), 'utf8');
  const head = html.match(/<head>([\s\S]*?)<\/head>/)?.[1] ?? '';
  const body = html.match(/<body[^>]*>([\s\S]*)<\/body>/)?.[1];
  if (body === undefined) throw new Error(`${slug}.html has no <body>`);
  return {
    title: decodeEntities(head.match(/<title>([\s\S]*?)<\/title>/)?.[1] ?? ''),
    description: decodeEntities(
      head.match(/<meta name="description" content="([^"]*)"/)?.[1] ?? '',
    ),
    headStyle: head.match(/<style>([\s\S]*?)<\/style>/)?.[1] ?? '',
    body,
  };
}

export function listSlugs(): string[] {
  return fs
    .readdirSync(PAGES_DIR)
    .filter((f) => f.endsWith('.html'))
    .map((f) => f.slice(0, -'.html'.length));
}

export function pageMetadata(slug: string): Metadata {
  const { title, description } = readPage(slug);
  const text = description ? { title, description } : { title };
  return {
    ...text,
    openGraph: { ...siteMetadata.openGraph, ...text },
    twitter: { ...siteMetadata.twitter, ...text },
  };
}

export function StaticPage({ slug }: { slug: string }) {
  const { headStyle, body } = readPage(slug);
  return (
    <>
      {headStyle && <style dangerouslySetInnerHTML={{ __html: headStyle }} />}
      {/* display:contents keeps the wrapper out of layout entirely. */}
      <div style={{ display: 'contents' }} dangerouslySetInnerHTML={{ __html: body }} />
    </>
  );
}
