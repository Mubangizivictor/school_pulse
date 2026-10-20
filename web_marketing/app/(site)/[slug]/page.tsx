import { StaticPage, listSlugs, pageMetadata } from '@/lib/static-page';

// Pages with their own route (home, and the reg-body pages under (reg)).
const OWN_ROUTE = new Set(['index', 'register-school', 'payment']);

export const dynamicParams = false;

export function generateStaticParams() {
  return listSlugs()
    .filter((slug) => !OWN_ROUTE.has(slug))
    .map((slug) => ({ slug }));
}

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props) {
  return pageMetadata((await params).slug);
}

export default async function Page({ params }: Props) {
  return <StaticPage slug={(await params).slug} />;
}
