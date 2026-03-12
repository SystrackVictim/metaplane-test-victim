# Metaplane Test Deployment Guide

## Step 1: Deploy Capture Server

```bash
cd /home/paulallen/vercel-research/metaplane-capture
npm install
vercel deploy --prod
# Note the URL: https://metaplane-capture-xxx.vercel.app
```

## Step 2: Update Test App Config

Edit `vercel.json` and replace `httpbin.org` with your capture URL:
```bash
sed -i 's|https://httpbin.org|https://YOUR-CAPTURE-URL.vercel.app/api/capture|g' vercel.json
```

## Step 3: Deploy Test App

```bash
cd /home/paulallen/vercel-research/metaplane-test
npm install
vercel deploy --prod
# Note the URL: https://metaplane-test-xxx.vercel.app
```

## Step 4: Configure Webhook (for A6 test)

1. Go to Vercel Dashboard > Project Settings > Webhooks
2. Add webhook URL: `https://YOUR-CAPTURE-URL.vercel.app/api/webhook`
3. Select "Deployment Created" event

## Step 5: Run Tests

```bash
export VICTIM_URL="https://metaplane-test-xxx.vercel.app"
export CAPTURE_URL="https://metaplane-capture-xxx.vercel.app"
export OAST_URL="https://your-id.oast.pro"  # From interactsh-client

./run-tests.sh
```

## Step 6: Check Results

1. Review output files in `/tmp/vercel_metaplane_*`
2. Check Vercel function logs for capture app
3. Check OAST dashboard for any callbacks

## Aggressive Config Test

To test if Vercel blocks internal IP rewrites:

1. Copy `vercel-aggressive.json` to `vercel.json`
2. Try to deploy: `vercel deploy`
3. Note which rules Vercel rejects at deploy time
4. Document the validation error messages

Expected outcome: Vercel should reject internal IP destinations (169.254.169.254, etc.)
If it doesn't reject them, that's a finding.
