#!/bin/bash
# Simple System Health Check for Dashboard

HOSTNAME=$(hostname)
UPTIME=$(uptime -p 2>/dev/null || echo "N/A")

# Disk usage
DISK_USAGE=$(df -h / 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}' || echo "0")

# Memory usage (if free is available)
if command -v free &>/dev/null; then
  MEMORY_USAGE=$(free 2>/dev/null | awk 'NR==2 {printf "%.0f", $3/$2 * 100}' || echo "0")
else
  MEMORY_USAGE="N/A"
fi

# Gateway status
GATEWAY_RUNNING="no"
if pgrep -f "openclaw.*gateway" >/dev/null 2>&1; then
  GATEWAY_RUNNING="yes"
fi

# Calculate health score
HEALTH_SCORE=100
[ "$DISK_USAGE" != "0" ] && [ "$DISK_USAGE" -ge 80 ] 2>/dev/null && HEALTH_SCORE=$((HEALTH_SCORE - 30))
[ "$MEMORY_USAGE" != "N/A" ] && [ "$MEMORY_USAGE" -ge 80 ] 2>/dev/null && HEALTH_SCORE=$((HEALTH_SCORE - 30))
[ "$GATEWAY_RUNNING" = "no" ] && HEALTH_SCORE=$((HEALTH_SCORE - 40))

if [ "$HEALTH_SCORE" -ge 80 ] 2>/dev/null; then
  STATUS="good"
elif [ "$HEALTH_SCORE" -ge 50 ] 2>/dev/null; then
  STATUS="warning"
else
  STATUS="critical"
fi

# Output JSON
cat <<EOF
{
  "hostname": "$HOSTNAME",
  "uptime": "$UPTIME",
  "disk_usage": $DISK_USAGE,
  "memory_usage": "$MEMORY_USAGE",
  "gateway_running": "$GATEWAY_RUNNING",
  "health_score": $HEALTH_SCORE,
  "status": "$STATUS",
  "timestamp": "$(date -Iseconds)"
}
EOF
