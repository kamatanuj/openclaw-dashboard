#!/bin/bash
# Dashboard Update Script
# This script is called by the dashboard update endpoint

LOG_FILE="/tmp/dashboard-update.log"
echo "=== Dashboard Update Started: $(date) ===" > "$LOG_FILE"

# Update Health Check
echo "[1/4] Running health check..." >> "$LOG_FILE"
cd /root/.openclaw/workspace/dashboard
bash health-check.sh >> "$LOG_FILE" 2>&1

# Update LLM Costs
echo "[2/4] Running LLM cost tracking..." >> "$LOG_FILE"
bash track-costs.sh >> "$LOG_FILE" 2>&1

# Update ElevenLabs Costs
echo "[3/4] Running ElevenLabs cost tracking..." >> "$LOG_FILE"
bash elevenlabs-costs.sh >> "$LOG_FILE" 2>&1

# Update GitHub
echo "[4/4] Pushing to GitHub..." >> "$LOG_FILE"
git add -A >> "$LOG_FILE" 2>&1
git commit -m "Manual update: $(date -u '+%Y-%m-%d %H:%M UTC')" >> "$LOG_FILE" 2>&1 || true
git push origin main >> "$LOG_FILE" 2>&1 || true

echo "=== Dashboard Update Completed: $(date) ===" >> "$LOG_FILE"
echo "Done"
