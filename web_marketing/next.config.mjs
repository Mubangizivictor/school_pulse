/** @type {import('next').NextConfig} */
const nextConfig = {
  // Fully static export: `next build` writes plain .html files to out/,
  // served by Firebase Hosting exactly like the old hand-written site.
  output: 'export',
  // platform -> out/platform.html (not platform/index.html), so every
  // existing "platform.html" link and Firebase cleanUrls keep working.
  trailingSlash: false,
  images: { unoptimized: true },
};

export default nextConfig;
