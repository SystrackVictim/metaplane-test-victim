// Edge function test endpoint
// Tests if Host header reaches edge runtime unsanitized

import { NextRequest, NextResponse } from 'next/server';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  const headers: Record<string, string> = {};

  request.headers.forEach((value, key) => {
    headers[key] = value;
  });

  return NextResponse.json({
    runtime: 'edge',
    timestamp: new Date().toISOString(),
    url: request.url,
    headers: headers,
    // Edge-specific header analysis
    hostHeader: request.headers.get('host'),
    xForwardedHost: request.headers.get('x-forwarded-host'),
    xForwardedFor: request.headers.get('x-forwarded-for'),
    xForwardedProto: request.headers.get('x-forwarded-proto'),
    // Vercel internal headers that might be present
    xVercelId: request.headers.get('x-vercel-id'),
    xMiddlewareRewrite: request.headers.get('x-middleware-rewrite'),
    xMiddlewarePrefetch: request.headers.get('x-middleware-prefetch'),
    xNowRouteMatches: request.headers.get('x-now-route-matches'),
    xMatchedPath: request.headers.get('x-matched-path'),
  });
}
