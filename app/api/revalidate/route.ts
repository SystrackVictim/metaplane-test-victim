// Revalidation endpoint for trustHostHeader SSRF testing
// This simulates the ISR revalidation flow

import { NextRequest, NextResponse } from 'next/server';
import { revalidatePath } from 'next/cache';

export async function GET(request: NextRequest) {
  const path = request.nextUrl.searchParams.get('path') || '/';

  // Log the request for debugging
  console.log('[REVALIDATE] Request received');
  console.log('[REVALIDATE] Host header:', request.headers.get('host'));
  console.log('[REVALIDATE] X-Forwarded-Host:', request.headers.get('x-forwarded-host'));
  console.log('[REVALIDATE] Path to revalidate:', path);

  try {
    // This triggers the revalidation flow that uses trustHostHeader
    revalidatePath(path);

    return NextResponse.json({
      revalidated: true,
      path: path,
      timestamp: new Date().toISOString(),
      hostUsed: request.headers.get('host'),
      message: 'If trustHostHeader is enabled and Host is attacker-controlled, the revalidation fetch went to attacker host'
    });
  } catch (error) {
    return NextResponse.json({
      revalidated: false,
      error: String(error),
      hostUsed: request.headers.get('host')
    }, { status: 500 });
  }
}
