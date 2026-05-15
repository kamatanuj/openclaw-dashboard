#!/bin/bash
# D-insights Voice Agent Cost Tracking with 30-Day History
# Polls both agents hourly and tracks daily costs

DATA_FILE="/root/.openclaw/workspace/dashboard/elevenlabs_costs.json"
HISTORY_FILE="/root/.openclaw/workspace/dashboard/elevenlabs_history.json"
LOG_FILE="/root/.openclaw/workspace/dashboard/elevenlabs_costs.log"

# Agent credentials
declare -A AGENTS
AGENTS["Rupeeboss"]="gKNyAo0UhrdRiQ7FAWVZ|3a708d1216251b9801380110a5ec11fb82f806545f70978ad63aa3283fbf23d4"
AGENTS["Livealth_Bio_Pharma"]="agent_7601k8ms1yhqf19tk684c03bfbst|eb2ad9409c505c87ba41ab90c20ffc942d752a19b9df671f10cce8ac1a496590"

# API base URL
BASE_URL="https://api.elevenlabs.io/v1/convai"
RATE_PER_MINUTE=0.08

# Get agent stats from conversations
get_agent_stats() {
    local agent_id="$1"
    local api_key="$2"
    
    local response=$(curl -s --compressed \
        -H "xi-api-key: $api_key" \
        -H "Content-Type: application/json" \
        "${BASE_URL}/conversations?agent_id=${agent_id}" 2>/dev/null)
    
    # Count conversations and total duration
    local calls=$(echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
convs = data.get('conversations', [])
print(len(convs))
" 2>/dev/null || echo "0")
    
    local total_secs=$(echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
convs = data.get('conversations', [])
total = sum(c.get('call_duration_secs', 0) for c in convs)
print(total)
" 2>/dev/null || echo "0")
    
    local minutes=$((total_secs / 60))
    local cost=$(python3 -c "print(f'{($minutes * 0.08):.2f}')" 2>/dev/null || echo "0.00")
    
    echo "$calls|$cost|$minutes"
}

# Format number with leading zero
format_num() {
    local num="$1"
    if [[ "$num" == .* ]]; then
        echo "0$num"
    else
        echo "$num"
    fi
}

# Main
TODAY=$(date +%Y-%m-%d)
CURRENT_TIME=$(date '+%Y-%m-%dT%H:%M:%S')
echo "[$CURRENT_TIME] Polling D-insights..." >> "$LOG_FILE"

# Get stats for each agent
rupeeboss_stats=$(get_agent_stats "gKNyAo0UhrdRiQ7FAWVZ" "3a708d1216251b9801380110a5ec11fb82f806545f70978ad63aa3283fbf23d4")
livealth_stats=$(get_agent_stats "agent_7601k8ms1yhqf19tk684c03bfbst" "eb2ad9409c505c87ba41ab90c20ffc942d752a19b9df671f10cce8ac1a496590")

# Parse stats
rupeeboss_calls=$(echo "$rupeeboss_stats" | cut -d'|' -f1)
rupeeboss_cost=$(format_num "$(echo "$rupeeboss_stats" | cut -d'|' -f2)")
rupeeboss_minutes=$(echo "$rupeeboss_stats" | cut -d'|' -f3)

livealth_calls=$(echo "$livealth_stats" | cut -d'|' -f1)
livealth_cost=$(format_num "$(echo "$livealth_stats" | cut -d'|' -f2)")
livealth_minutes=$(echo "$livealth_stats" | cut -d'|' -f3)

# Calculate totals
total_calls=$((rupeeboss_calls + livealth_calls))
total_cost=$(python3 -c "print(f'{(float('$rupeeboss_cost') + float('$livealth_cost')):.2f}')")

# Build JSON with proper number formatting
cat > "$DATA_FILE" << EOF
{
  "last_updated": "$CURRENT_TIME",
  "today": "$TODAY",
  "agents": {
    "Rupeeboss": {"agent_id": "gKNyAo0UhrdRiQ7FAWVZ", "calls": $rupeeboss_calls, "cost": $rupeeboss_cost, "minutes": $rupeeboss_minutes},
    "Livealth_Bio_Pharma": {"agent_id": "agent_7601k8ms1yhqf19tk684c03bfbst", "calls": $livealth_calls, "cost": $livealth_cost, "minutes": $livealth_minutes}
  },
  "totals": {"calls": $total_calls, "cost": $total_cost}
}
EOF

echo "Data saved: $DATA_FILE" >> "$LOG_FILE"

# Update history
python3 << PYEOF
import json

today = "$TODAY"
history_file = "$HISTORY_FILE"

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except:
    history = {"history": []}

# Check if today exists, update or add
found = False
for entry in history["history"]:
    if entry["date"] == today:
        entry["Rupeeboss"] = {"calls": $rupeeboss_calls, "cost": float("$rupeeboss_cost")}
        entry["Livealth_Bio_Pharma"] = {"calls": $livealth_calls, "cost": float("$livealth_cost")}
        found = True
        break

if not found:
    history["history"].append({
        "date": today,
        "Rupeeboss": {"calls": $rupeeboss_calls, "cost": float("$rupeeboss_cost")},
        "Livealth_Bio_Pharma": {"calls": $livealth_calls, "cost": float("$livealth_cost")}
    })

history["history"] = history["history"][-30:]  # Keep 30 days

with open(history_file, 'w') as f:
    json.dump(history, f, indent=2)

print(f"History: {len(history['history'])} entries")
PYEOF

# Summary
echo "=== D-insights Stats ==="
echo "Rupeeboss: $rupeeboss_calls calls, \$$rupeeboss_cost, $rupeeboss_minutes min"
echo "Livealth: $livealth_calls calls, \$$livealth_cost, $livealth_minutes min"
echo "Total: $total_calls calls, \$$total_cost"

# Push to GitHub
cd /root/.openclaw/workspace/dashboard || exit 1

# Check if there are changes
if git diff --quiet && git diff --cached --quiet; then
    echo "📋 No changes to push"
    exit 0
fi

# Add, commit, and push
git add -A
git commit -m "Auto-update: ElevenLabs costs $(date -u '+%Y-%m-%d %H:%M UTC')"
git push origin main

echo "🚀 ElevenLabs costs pushed to GitHub"
