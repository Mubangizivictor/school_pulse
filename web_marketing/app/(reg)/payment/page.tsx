import { StaticPage, pageMetadata } from '@/lib/static-page';

export const metadata = pageMetadata('payment');

export default function PaymentPage() {
  return <StaticPage slug="payment" />;
}
