# Jules CLI + GitHub CLI Workflow Skills Suite

**Created:** 2026-05-17  
**Author:** woofleek-svg  
**Status:** Production-tested  
**Last Updated:** 2026-05-17

---

## Overview

This document captures the complete workflow for using Jules CLI (async AI coding agent) with GitHub CLI (headless PR management) to create a reusable, iterative AI-assisted development pipeline.

**Core Concept:** Jules runs tasks asynchronously in remote VMs, creates PRs automatically, and responds to PR comments for iterative feedback. GH CLI handles PR review, commenting, and merging.

---

## Skill 1: Jules Session Management

### 1.1 Create a New Session

```bash
# Create a task for a connected repo
jules remote new --repo woofleek-svg/<repo> "<task description>"
```

**Example:**
```bash
jules remote new --repo woofleek-svg/gh-jules-workflow-development \
  "Add a CONTRIBUTING.md file explaining project structure, setup instructions, and Jules CLI usage guidelines"
```

**Output:**
```
Session is created.
ID: <SESSION_ID>
Task: <task description>
URL: https://jules.google.com/session/<SESSION_ID>
```

### 1.2 Check Session Status

```bash
# List all sessions for the current user
jules remote list --session 2>&1

# Check a specific session
jules remote list --session 2>&1 | grep <SESSION_ID>
```

**Session States:**
- `Planning` → Jules is analyzing the task
- `In Progress` → Jules is executing
- `Completed` → Jules finished (check for PR)

### 1.3 Poll Until Completion

```bash
# Wait for session to complete (max 5 checks, 30s intervals)
for i in 1 2 3 4 5; do
  echo "Check $i at $(date)"
  jules remote list --session 2>&1 | grep <SESSION_ID>
  sleep 30
done
```

### 1.4 Apply Session Changes Locally

```bash
# Pull the diff from a completed session
jules remote pull --session <SESSION_ID>
```

**Output:** Shows the git diff for manual review.

### 1.5 Teleport (Clone + Apply)

```bash
# Clone the repo and apply session changes in one step
jules teleport <SESSION_ID>
```

**Behavior:**
- If no working directory: clones repo, checks out session's starting branch, applies patch
- If in a working directory: applies patch to current repo if it matches the session's repo

---

## Skill 2: PR Creation & Management

### 2.1 Create PR from Jules Branch

Jules creates branches automatically. To create a PR:

```bash
# Method 1: Use gh pr create (when branches share history)
cd <repo-directory>
gh pr create \
  --base main \
  --head <branch-name> \
  --title "<PR title>" \
  --body "## Changes\n- <summary>\n\n## Task\n<task description>"

# Method 2: Use gh pr create with --json for machine parsing
gh pr create \
  --base main \
  --head <branch-name> \
  --json title,body \
  --repo <owner>/<repo>
```

**Common Issues:**
- **"Branch has no history in common with main"** → Merge main into the branch first:
  ```bash
  git checkout <branch>
  git merge main
  git push origin <branch> --force
  ```

### 2.2 Review a PR

```bash
# View PR details
gh pr view <PR_NUMBER> --json title,body,state,files,additions,deletions,commits,url

# View the diff
gh pr diff <PR_NUMBER>

# View commits
gh pr commits <PR_NUMBER>
```

### 2.3 Merge a PR

```bash
# Squash merge and delete branch
gh pr merge <PR_NUMBER> --squash --delete-branch

# Merge with merge commit (preserves branch history)
gh pr merge <PR_NUMBER> --merge --delete-branch
```

### 2.4 Close a PR

```bash
# Close and delete branch
gh pr close <PR_NUMBER> --delete-branch
```

---

## Skill 3: Feedback Loop (Iterative Improvement)

### 3.1 Post Feedback via PR Comment

Jules monitors PR comments. Post detailed feedback to trigger resubmission:

```bash
gh pr comment <PR_NUMBER> \
  --repo <owner>/<repo> \
  --body "This looks good but please also add:
1. <specific requirement>
2. <another requirement>
3. <third requirement>"
```

### 3.2 Create a New Session with Feedback

Jules sessions are one-shot. To incorporate feedback, create a NEW session:

```bash
jules remote new --repo <owner>/<repo> \
  --session "Update <file> to add: 1) <requirement>, 2) <requirement>, 3) <requirement>"
```

**Key Points:**
- Reference the previous PR/branch in the task description if needed
- Be specific about what to add/change
- Jules will create a new PR with the updated changes

### 3.3 Example Feedback Cycle

```bash
# Step 1: Create initial task
jules remote new --repo woofleek-svg/my-repo "Add README.md with project setup"
# → Session 12345, PR #1 created

# Step 2: Review and comment
gh pr comment 1 --body "Good start. Please add:
- Installation instructions
- Usage examples
- Contribution guidelines"

# Step 3: Create follow-up session
jules remote new --repo woofleek-svg/my-repo \
  "Update README.md to include: installation instructions, usage examples, contribution guidelines"
# → Session 67890, PR #2 created with updated README

# Step 4: Merge when satisfied
gh pr merge 2 --squash --delete-branch
```

---

## Skill 4: Template Creation

### 4.1 AGENTS.md Template

Jules reads `AGENTS.md` files for project-specific rules:

```markdown
# AGENTS.md

## Project Rules
- Use TypeScript for all new code
- Follow Prettier formatting (2-space indent)
- Write tests for all new features
- Run linting before committing

## Coding Conventions
- Prefix private methods with underscore
- Use async/await, not callbacks
- Handle errors with try/catch + custom Error classes

## Testing Requirements
- All new functions must have unit tests
- Test edge cases (empty input, null, invalid types)
- Aim for >80% coverage
```

### 4.2 CONTRIBUTING.md Template

```markdown
# Contributing

## Jules CLI Guidelines

When using Jules for this project:

1. **Provide Clear Prompts**
   - Be specific about what you want
   - Include file paths and line numbers
   - Mention edge cases to handle

2. **Use AGENTS.md**
   - Jules reads this for project rules
   - Update it when conventions change

3. **Review Changes**
   - Always check the diff before merging
   - Test locally if possible

4. **Encourage Testing**
   - Ask Jules to write tests for new features
   - Verify tests pass before merging
```

### 4.3 PR Template

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Changes
- <summary of changes>

## Task
<original task description from Jules session>

## Testing
- [ ] Unit tests pass
- [ ] Manual testing done
- [ ] No regressions introduced

## Notes
- <any special considerations>
```

---

## Skill 5: Workflow Scripts

### 5.1 Wait for Session to Complete

**Script:** `scripts/wait-for-session.sh`

```bash
#!/usr/bin/env bash
# Wait for a Jules session to complete
# Usage: wait-for-session.sh <SESSION_ID> [MAX_CHECKS] [INTERVAL_SECS]

SESSION_ID="${1:?Session ID required}"
MAX_CHECKS="${2:-5}"
INTERVAL="${3:-30}"

for i in $(seq 1 "$MAX_CHECKS"); do
  echo "Check $i at $(date)"
  STATUS=$(jules remote list --session 2>&1 | grep "$SESSION_ID" | awk '{print $NF}')
  
  if [[ "$STATUS" == "Completed" ]]; then
    echo "✅ Session completed!"
    exit 0
  fi
  
  if [[ $i -lt "$MAX_CHECKS" ]]; then
    echo "Status: $STATUS - waiting ${INTERVAL}s..."
    sleep "$INTERVAL"
  fi
done

echo "⚠️ Session still running after $MAX_CHECKS checks"
exit 1
```

### 5.2 Jules Task Pipeline

**Script:** `scripts/jules-task.sh`

```bash
#!/usr/bin/env bash
# Run a Jules task and handle the PR automatically
# Usage: jules-task.sh <owner>/<repo> "<task description>"

OWNER_REPO="${1:?Owner/repo required}"
TASK="${2:?Task description required}"

echo "🚀 Creating Jules session..."
SESSION=$(jules remote new --repo "$OWNER_REPO" "$TASK" 2>&1)
SESSION_ID=$(echo "$SESSION" | grep "ID:" | awk '{print $2}')

echo "📋 Session ID: $SESSION_ID"
echo "⏳ Waiting for completion..."

# Wait for session
for i in $(seq 1 10); do
  STATUS=$(jules remote list --session 2>&1 | grep "$SESSION_ID" | awk '{print $NF}')
  if [[ "$STATUS" == "Completed" ]]; then
    echo "✅ Session completed!"
    break
  fi
  sleep 30
done

# Find the new PR
echo "🔍 Looking for PR..."
cd "$(dirname "$0")/../"
BRANCH=$(git branch -a | grep "$SESSION_ID" | head -1 | sed 's|remotes/origin/||' | sed 's|^\*||')
if [[ -z "$BRANCH" ]]; then
  echo "❌ No branch found for session $SESSION_ID"
  exit 1
fi

echo "📦 Creating PR..."
gh pr create \
  --base main \
  --head "$BRANCH" \
  --title "docs: $(echo "$TASK" | head -1)" \
  --body "## Task\n$TASK\n\n## Session\n$SESSION_ID"
```

---

## Skill 6: Troubleshooting

### 6.1 Common Issues

| Issue | Solution |
|-------|----------|
| `api error: status 400` | Check Jules CLI version (`jules --version`), ensure repo is connected |
| `Branch has no history in common` | Merge main into the branch: `git checkout <branch> && git merge main` |
| `gh pr comment` fails | Verify PR number and repo ownership |
| Session stuck in `Planning` | Wait longer or check Jules web UI for errors |
| `jules teleport` fails | Ensure you're in a valid git repo directory |

### 6.2 Debug Commands

```bash
# Check Jules CLI version
jules --version

# List all sessions (check for stuck sessions)
jules remote list --session

# Check repo branches
git branch -a

# View recent commits
git log --oneline -5

# Check gh auth status
gh auth status
```

### 6.3 Session State File

Track session state for automation:

```bash
# Save session info
echo '{"id": "<SESSION_ID>", "task": "<TASK>", "status": "created", "pr": null}' > /tmp/jules-session.json

# Update status
jq '.status = "completed"' /tmp/jules-session.json > /tmp/jules-session.json.tmp && mv /tmp/jules-session.json.tmp /tmp/jules-session.json
```

---

## Skill 7: Best Practices

### 7.1 Task Description Best Practices

✅ **Good:**
- "Add error handling to the login function in auth.py"
- "Update README.md to include installation steps and usage examples"
- "Refactor the database connection code to use connection pooling"

❌ **Bad:**
- "Fix the code"
- "Make it better"
- "Add stuff"

### 7.2 Feedback Best Practices

- Be specific about what to add/change
- Reference file names and line numbers
- Provide examples of desired output
- Break complex feedback into multiple comments
- Use bullet points for clarity

### 7.3 PR Review Best Practices

- Review diffs before merging
- Test changes locally when possible
- Check for unintended side effects
- Verify tests pass
- Merge with squash for clean history

---

## Quick Reference Card

```bash
# Create session
jules remote new --repo <owner>/<repo> "<task>"

# Check status
jules remote list --session | grep <SESSION_ID>

# Pull changes
jules remote pull --session <SESSION_ID>

# Teleport
jules teleport <SESSION_ID>

# Create PR
gh pr create --base main --head <branch> --title "<title>" --body "<body>"

# Comment on PR
gh pr comment <number> --body "<feedback>"

# Merge PR
gh pr merge <number> --squash --delete-branch

# Close PR
gh pr close <number> --delete-branch
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-17 | Initial documentation based on testing |

---

## Related Files

- `scripts/` - Reusable shell scripts
- `templates/` - AGENTS.md, CONTRIBUTING.md, PR templates
- `workflows/` - Example workflow definitions
