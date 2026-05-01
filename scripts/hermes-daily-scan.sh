#!/bin/bash
# Hermes Daily Career Scan
# Run this daily on your NUC to scan for matching jobs
# Results sync via git to your Mac/Obsidian

set -e

# Config
CAREER_OPS_DIR="${CAREER_OPS_DIR:-$HOME/career-ops}"
OBSIDIAN_CAREER_DIR="${OBSIDIAN_CAREER_DIR:-$HOME/shared-brain/04_Areas/Career}"  # Default for Rhiannon's NUC; override with env var for other setups
LOG_FILE="$CAREER_OPS_DIR/logs/hermes-scan.log"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

# Telegram notification (optional - set these env vars)
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

# Logging
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "[$DATE $TIME] Hermes Career Scan Starting"
echo "=========================================="

cd "$CAREER_OPS_DIR"

# Pull latest from git
echo "[1/5] Pulling latest from git..."
git pull origin main --rebase || true

# Count existing pipeline entries before scan
BEFORE_COUNT=$(grep -cE "^- (\[ \] )?http" data/pipeline.md 2>/dev/null || true)
BEFORE_COUNT=${BEFORE_COUNT:-0}

# Run the scan
echo "[2/5] Running job scan..."
node scan.mjs 2>&1

# Count after scan
AFTER_COUNT=$(grep -cE "^- (\[ \] )?http" data/pipeline.md 2>/dev/null || true)
AFTER_COUNT=${AFTER_COUNT:-0}
NEW_JOBS=$((AFTER_COUNT - BEFORE_COUNT))

echo "[3/5] Scan complete. Found $NEW_JOBS new job(s)."

# Update Obsidian daily scan file if path is set
if [ -n "$OBSIDIAN_CAREER_DIR" ] && [ -d "$OBSIDIAN_CAREER_DIR" ]; then
    echo "[3.5/5] Updating Obsidian daily scan..."
    DAILY_SCAN_FILE="$OBSIDIAN_CAREER_DIR/Job Search/Daily Scans/$DATE.md"
    mkdir -p "$(dirname "$DAILY_SCAN_FILE")"

    cat > "$DAILY_SCAN_FILE" << OBSIDIAN_EOF
# Job Scan: $DATE

> **Scanned:** career-ops portal list
> **Time:** $TIME
> **New matches:** $NEW_JOBS

---

## New Matches Found

$(if [ "$NEW_JOBS" -gt 0 ]; then
    git diff data/pipeline.md | grep -E "^\+- " | sed 's/^+//'
else
    echo "*No new matches today.*"
fi)

---

## Pipeline Status

- **Total in pipeline:** $AFTER_COUNT jobs
- **Scan history entries:** $(wc -l < data/scan-history.tsv)

---

*Scanned by Hermes at $TIME*
OBSIDIAN_EOF
fi

# Commit and push if there are changes
echo "[4/5] Checking for changes to commit..."
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "scan($DATE): found $NEW_JOBS new job(s)

Automated scan by Hermes
Time: $TIME"

    echo "[5/5] Pushing to git..."
    git push origin main

    COMMIT_MSG="Pushed $NEW_JOBS new job(s) to git"
else
    COMMIT_MSG="No new jobs found"
    echo "[5/5] No changes to push."
fi

# Telegram notification
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    echo "Sending Telegram notification..."

    if [ "$NEW_JOBS" -gt 0 ]; then
        MESSAGE="🔍 *Career Scan Complete*

📅 $DATE at $TIME
✨ *$NEW_JOBS new job(s) found*

Check your pipeline:
\`/career-ops pipeline\`"
    else
        MESSAGE="🔍 *Career Scan Complete*

📅 $DATE at $TIME
No new matches today.

Pipeline has $AFTER_COUNT jobs pending."
    fi

    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$MESSAGE" \
        -d parse_mode="Markdown" > /dev/null
fi

echo "=========================================="
echo "[$DATE $TIME] Hermes Career Scan Complete"
echo "New jobs: $NEW_JOBS | Total pipeline: $AFTER_COUNT"
echo "=========================================="
