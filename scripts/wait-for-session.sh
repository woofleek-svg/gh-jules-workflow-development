#!/usr/bin/env bash
# Wait for a Jules session to complete
# Usage: wait-for-session.sh <SESSION_ID> [MAX_CHECKS] [INTERVAL_SECS]

set -euo pipefail

SESSION_ID="${1:?Session ID required}"
MAX_CHECKS="${2:-5}"
INTERVAL="${3:-30}"

echo "⏳ Waiting for session $SESSION_ID to complete..."
echo "   Max checks: $MAX_CHECKS | Interval: ${INTERVAL}s"
echo ""

for i in $(seq 1 "$MAX_CHECKS"); do
  echo "Check $i at $(date)"
  STATUS=$(jules remote list --session 2>&1 | grep "$SESSION_ID" | awk '{print $NF}')
  
  if [[ "$STATUS" == "Completed" ]]; then
    echo ""
    echo "✅ Session completed!"
    exit 0
  fi
  
  if [[ $i -lt "$MAX_CHECKS" ]]; then
    echo "   Status: $STATUS - waiting ${INTERVAL}s..."
    sleep "$INTERVAL"
  fi
done

echo ""
echo "⚠️ Session still running after $MAX_CHECKS checks"
exit 1
