import { RootHead } from '@/lib/root-head';

// register-school and payment use <body class="reg-body">.
export default function RegLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <RootHead />
      <body className="reg-body">{children}</body>
    </html>
  );
}
