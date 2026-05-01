# Hermes Scripts

Scripts for running career-ops on your NUC via Hermes Agent.

## Setup (Run Once)

```bash
curl -fsSL https://raw.githubusercontent.com/rhiannonschira-glitch/career-ops/main/scripts/hermes-setup.sh | bash
```

Or manually:
```bash
git clone https://github.com/rhiannonschira-glitch/career-ops ~/career-ops
cd ~/career-ops
npm install
chmod +x scripts/*.sh
```

## Daily Scan

```bash
cd ~/career-ops && ./scripts/hermes-daily-scan.sh
```

### What it does:
1. Pulls latest from git
2. Runs `scan.mjs` (zero Claude tokens — direct API calls)
3. Counts new matches
4. Updates Obsidian daily scan file (if `OBSIDIAN_CAREER_DIR` is set)
5. Commits and pushes changes to git
6. Sends Telegram notification (if configured)

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `CAREER_OPS_DIR` | No | Path to career-ops (default: `~/career-ops`) |
| `OBSIDIAN_CAREER_DIR` | No | Path to Obsidian Career folder (for direct updates via Syncthing) |
| `TELEGRAM_BOT_TOKEN` | No | Telegram bot token for notifications |
| `TELEGRAM_CHAT_ID` | No | Telegram chat ID for notifications |

### Telegram Setup

1. Create a bot via [@BotFather](https://t.me/botfather)
2. Get your chat ID via [@userinfobot](https://t.me/userinfobot)
3. Set environment variables:
   ```bash
   export TELEGRAM_BOT_TOKEN='123456:ABC-DEF...'
   export TELEGRAM_CHAT_ID='your-chat-id'
   ```

### Cron Setup

Run daily at 9am:
```bash
crontab -e
# Add this line:
0 9 * * * cd $HOME/career-ops && ./scripts/hermes-daily-scan.sh
```

### Hermes Task

Tell Hermes:
> "Every day at 9am, run `~/career-ops/scripts/hermes-daily-scan.sh` and let me know if there are new job matches."

## Sync Flow

```
NUC (Hermes)                    Mac (You)
     |                              |
     | 1. scan.mjs runs             |
     | 2. new jobs → pipeline.md    |
     | 3. git push                  |
     |                              |
     |          git pull            |
     |----------------------------->|
     |                              |
     |        (or Syncthing)        |
     |----------------------------->| 
     |                              | 
     |                    Obsidian shows new jobs
```
