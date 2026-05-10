#!/bin/bash
# Health Check for OpenClaw
# Outputs JSON with system health metrics

HEALTH_FILE="/root/.openclaw/workspace/dashboard/health.json"

# Get current timestamp
TIMESTAMP=$(date -u "+%Y-%m-%dT%H:%M:%S+00:00")
DATE_ONLY=$(date -u "+%Y-%m-%d")

# System metrics
HOSTNAME=$(hostname)
UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F',' '{print $1}' | sed 's/.*up //')
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')

# Check if gateway is running (matches 'openclaw' and 'gateway' pattern)
GATEWAY_RUNNING=$(pgrep -f "openclaw.*gateway" > /dev/null && echo "yes" || echo "no")

# Calculate health score
HEALTH_SCORE=100
if [ "$GATEWAY_RUNNING" != "yes" ]; then
  HEALTH_SCORE=$((HEALTH_SCORE - 30))
fi
if [ "$DISK_USAGE" -gt 80 ]; then
  HEALTH_SCORE=$((HEALTH_SCORE - 20))
fi
if [ "$MEMORY_USAGE" -gt 90 ]; then
  HEALTH_SCORE=$((HEALTH_SCORE - 15))
fi

# Determine status
if [ "$HEALTH_SCORE" -ge 90 ]; then
  STATUS="good"
elif [ "$HEALTH_SCORE" -ge 70 ]; then
  STATUS="warning"
else
  STATUS="critical"
fi

# Write health data
cat > "$HEALTH_FILE" <<EOF
{
  "hostname": "$HOSTNAME",
  "uptime": "$UPTIME",
  "disk_usage": $DISK_USAGE,
  "memory_usage": "$MEMORY_USAGE",
  "gateway_running": "$GATEWAY_RUNNING",
  "health_score": $HEALTH_SCORE,
  "status": "$STATUS",
  "timestamp": "$TIMESTAMP",
  "date": "$DATE_ONLY"
}
EOF

echo "✅ Health check updated: $STATUS (score: $HEALTH_SCORE)"
