import type { Metadata } from 'next';

// Link previews for every page; pages only set their own title/description.
export const siteMetadata: Metadata = {
  metadataBase: new URL('https://schoolpulseapp.com'),
  openGraph: {
    type: 'website',
    siteName: 'School Pulse',
    images: [{ url: '/og-image.png', width: 1200, height: 630, alt: 'School Pulse' }],
  },
  twitter: {
    card: 'summary_large_image',
    images: ['/og-image.png'],
  },
};

// Shared <head> links every original page carried.
export function RootHead() {
  return (
    <head>
      <link rel="stylesheet" href="css/style.css" />
      <link rel="icon" href="favicon.ico" sizes="any" />
      <link rel="icon" type="image/svg+xml" href="icon.svg" />
      <link rel="apple-touch-icon" href="apple-touch-icon.png" />
    </head>
  );
}
