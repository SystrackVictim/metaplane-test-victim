// ISR page for testing revalidation with trustHostHeader
// This page has a short revalidation period for testing

export const revalidate = 10; // Revalidate every 10 seconds

export default async function ISRPage() {
  const timestamp = new Date().toISOString();

  return (
    <div>
      <h1>ISR Test Page</h1>
      <p>Generated at: {timestamp}</p>
      <p>This page revalidates every 10 seconds.</p>
      <p>Test revalidation with: /api/revalidate?path=/isr-page</p>
    </div>
  );
}
