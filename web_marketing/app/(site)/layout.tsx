import { RootHead, siteMetadata } from '@/lib/root-head';

export const metadata = siteMetadata;

export default function SiteLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <RootHead />
      <body>{children}</body>
    </html>
  );
}
