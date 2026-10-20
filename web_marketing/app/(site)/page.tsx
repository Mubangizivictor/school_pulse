import { StaticPage, pageMetadata } from '@/lib/static-page';

export const metadata = pageMetadata('index');

export default function HomePage() {
  return <StaticPage slug="index" />;
}
