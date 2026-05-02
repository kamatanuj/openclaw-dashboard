#!/bin/bash
# Cost Tracking for OpenClaw LLM Usage
# Outputs JSON with daily costs broken down by model

LOG_DIR="/root/.openclaw/logs"
COST_FILE="/root/.openclaw/workspace/dashboard/costs.json"

# Get current date
TODAY=$(date "+%Y-%m-%d")

# Initialize costs JSON if not exists
if [ ! -f "$COST_FILE" ]; then
  echo '{"costs": []}' > "$COST_FILE"
fi

# Calculate costs based on model usage (simplified estimation)
# This would normally parse actual usage logs
# For now, we'll create a sample structure

# Get OpenClaw config to see which models are used
CONFIG="/root/.openclaw/openclaw.json"
if [ -f "$CONFIG" ]; then
  # Extract model info (simplified)
  MAIN_MODEL=$(grep -o '"model"[[:space:]]*"[A-Za-z0-9:./-]*"' "$CONFIG" 2>/dev/null | head -1 | sed 's/.*"//; s/".*//' || echo "unknown")
else
  MAIN_MODEL="unknown"
fi

# Generate sample cost data (in a real scenario, this would parse actual logs)
# For now, create/update today's entry with estimated costs
cat > /tmp/costs_update.py <<'PYEOF'
import json
from datetime import datetime, timedelta

cost_file = "/root/.openclaw/workspace/dashboard/costs.json"
today = datetime.now().strftime("%Y-%m-%d")

# Sample data structure (in production, this would be real usage data)
models = [
    {"model": "ollama/gemma3:12b", "cost_per_1k": 0.0, "calls": 15},
    {"model": "openrouter/google/gemini-3.1-flash", "cost_per_1k": 0.0, "calls": 8},
    {"model": "openrouter/tencent/hy3-preview:free", "cost_per_1k": 0.0, "calls": 5}
]

# Calculate total cost (free models = $0)
total_cost = 0.0
for m in models:
    m["cost"] = m["calls"] * m["cost_per_1k"] / 1000
    total_cost += m["cost"]

# Read existing data
try:
    with open(cost_file, "r") as f:
        data = json.load(f)
except:
    data = {"costs": []}

# Check if today exists
today_entry = None
for entry in data["costs"]:
    if entry["date"] == today:
        today_entry = entry
        break

if today_entry:
    today_entry["models"] = models
    today_entry["total_cost"] = total_cost
else:
    data["costs"].append({
        "date": today,
        "models": models,
        "total_cost": total_cost
    })

# Keep only last 7 days
data["costs"] = sorted(data["costs"], key=lambda x: x["date"], reverse=True)[:7]

# Write back
with open(cost_file, "w") as f:
    json.dump(data, f, indent=2)

print(f"✅ Costs updated for {today}: ${total_cost}")
PYEOF'

python3 /tmp/costs_update.py
