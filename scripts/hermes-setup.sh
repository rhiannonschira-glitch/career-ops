#!/bin/bash
# Hermes Setup Script
# Run this ONCE on your NUC to set up career-ops

set -e

echo "================================"
echo "Hermes Career-Ops Setup"
echo "================================"

# Clone if not exists
if [ ! -d "$HOME/career-ops" ]; then
    echo "[1/4] Cloning career-ops..."
    git clone https://github.com/rhiannonschira-glitch/career-ops "$HOME/career-ops"
else
    echo "[1/4] career-ops already exists, pulling latest..."
    cd "$HOME/career-ops" && git pull origin main
fi

cd "$HOME/career-ops"

# Install dependencies
echo "[2/4] Installing Node.js dependencies..."
npm install

# Create logs directory
echo "[3/4] Creating logs directory..."
mkdir -p logs

# Make scripts executable
echo "[4/4] Making scripts executable..."
chmod +x scripts/*.sh

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Set up Telegram notifications (optional):"
echo "   export TELEGRAM_BOT_TOKEN='your-bot-token'"
echo "   export TELEGRAM_CHAT_ID='your-chat-id'"
echo ""
echo "2. If using Syncthing to sync Obsidian:"
echo "   export OBSIDIAN_CAREER_DIR='/path/to/synced/04_Areas/Career'"
echo ""
echo "3. Test the scan:"
echo "   ./scripts/hermes-daily-scan.sh"
echo ""
echo "4. Add to Hermes daily tasks or cron:"
echo "   0 9 * * * cd $HOME/career-ops && ./scripts/hermes-daily-scan.sh"
echo ""
