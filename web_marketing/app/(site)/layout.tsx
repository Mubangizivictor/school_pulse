import { RootHead } from '@/lib/root-head';

export default function SiteLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <RootHead />
      <body>{children}</body>
    </html>
  );
}
