#!/bin/bash
# Deploy dashboard to Cloudflare Pages after JSON updates

DASHBOARD_DIR="/root/.openclaw/workspace/dashboard"

# Load credentials from .env file (not tracked by git)
if [ -f "$DASHBOARD_DIR/.env" ]; then
  source "$DASHBOARD_DIR/.env"
else
  echo "❌ .env file not found! Create it with CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID"
  exit 1
fi

cd "$DASHBOARD_DIR" || exit 1

# Add and commit changes
git add -A
git commit -m "Auto-update: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || echo "No changes to commit"

# Push to GitHub
git push origin main 2>&1 | grep -E "(error|success|To)" || true

# Deploy to Cloudflare Pages
echo "🚀 Deploying to Cloudflare Pages..."
wrangler pages deploy . \
  --project-name=openclaw-dashboard \
  --branch=main 2>&1 | grep -E "(Successfully|https|ERROR)" | head -5

echo "✅ Deploy complete!"
