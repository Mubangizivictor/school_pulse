import { RootHead, siteMetadata } from '@/lib/root-head';

export const metadata = siteMetadata;

// register-school and payment use <body class="reg-body">.
export default function RegLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <RootHead />
      <body className="reg-body">{children}</body>
    </html>
  );
}
