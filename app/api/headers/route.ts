// Test endpoint: logs all incoming headers
// Used to verify which headers reach the application layer

import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const headers: Record<string, string> = {};

  request.headers.forEach((value, key) => {
    headers[key] = value;
  });

  // Log to serverless function logs
  console.log('[METAPLANE-TEST] Headers received:', JSON.stringify(headers, null, 2));

  return NextResponse.json({
    timestamp: new Date().toISOString(),
    method: 'GET',
    url: request.url,
    headers: headers,
    // Specific headers of interest for Metaplane testing
    hostHeader: request.headers.get('host'),
    xForwardedHost: request.headers.get('x-forwarded-host'),
    xOriginalHost: request.headers.get('x-original-host'),
    xVercelId: request.headers.get('x-vercel-id'),
    xVercelOidcToken: request.headers.get('x-vercel-oidc-token') ? '[PRESENT]' : null,
    xVercelProtectionBypass: request.headers.get('x-vercel-protection-bypass') ? '[PRESENT]' : null,
  });
}

export async function POST(request: NextRequest) {
  return GET(request);
}
