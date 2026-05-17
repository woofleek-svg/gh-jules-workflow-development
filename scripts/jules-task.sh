#!/usr/bin/env bash
# Run a Jules task and handle the PR automatically
# Usage: jules-task.sh <owner>/<repo> "<task description>"

set -euo pipefail

OWNER_REPO="${1:?Owner/repo required}"
TASK="${2:?Task description required}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Creating Jules session..."
echo "   Repo: $OWNER_REPO"
echo "   Task: $TASK"
echo ""

# Create session
SESSION=$(jules remote new --repo "$OWNER_REPO" "$TASK" 2>&1)
SESSION_ID=$(echo "$SESSION" | grep "ID:" | awk '{print $2}')

if [[ -z "$SESSION_ID" ]]; then
  echo "❌ Failed to create session"
  echo "$SESSION"
  exit 1
fi

echo "📋 Session ID: $SESSION_ID"
echo ""

# Wait for session to complete
echo "⏳ Waiting for completion..."
for i in $(seq 1 10); do
  STATUS=$(jules remote list --session 2>&1 | grep "$SESSION_ID" | awk '{print $NF}')
  if [[ "$STATUS" == "Completed" ]]; then
    echo "✅ Session completed!"
    break
  fi
  if [[ $i -lt 10 ]]; then
    echo "   Status: $STATUS - waiting 30s..."
  fi
  sleep 30
done

# Find the branch
echo ""
echo "🔍 Looking for PR..."
cd "$REPO_DIR"
BRANCH=$(git branch -a | grep "$SESSION_ID" | head -1 | sed 's|remotes/origin/||' | sed 's|^\*||')

if [[ -z "$BRANCH" ]]; then
  echo "❌ No branch found for session $SESSION_ID"
  echo "   Available branches:"
  git branch -a
  exit 1
fi

echo "📦 Branch: $BRANCH"

# Create PR
echo ""
echo "📝 Creating PR..."
PR_TITLE="docs: $(echo "$TASK" | head -1)"
PR_BODY="## Task
$TASK

## Session
Session ID: $SESSION_ID"

PR_URL=$(gh pr create \
  --base main \
  --head "$BRANCH" \
  --title "$PR_TITLE" \
  --body "$PR_BODY" 2>&1 | tail -1)

if [[ -z "$PR_URL" || "$PR_URL" == *"Error"* ]]; then
  echo "❌ Failed to create PR"
  echo "$PR_URL"
  exit 1
fi

echo "✅ PR created: $PR_URL"
echo ""
echo "🎉 Task complete! You can now review and merge the PR."
