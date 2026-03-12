export default function Home() {
  return (
    <div style={{ padding: '20px', fontFamily: 'monospace' }}>
      <h1>Metaplane Test App</h1>
      <p>Authorized Bug Bounty Research - HackerOne: SysTrack</p>
      <hr />
      <h2>Test Endpoints:</h2>
      <ul>
        <li><a href="/api/headers">/api/headers</a> - Log all incoming headers</li>
        <li><a href="/api/edge-test">/api/edge-test</a> - Edge function header test</li>
        <li><a href="/api/revalidate?path=/isr-page">/api/revalidate</a> - ISR revalidation test</li>
        <li><a href="/isr-page">/isr-page</a> - ISR page (10s revalidation)</li>
        <li><a href="/proxy/headers">/proxy/headers</a> - External rewrite proxy test</li>
        <li><a href="/external-test">/external-test</a> - External destination test</li>
      </ul>
    </div>
  );
}
