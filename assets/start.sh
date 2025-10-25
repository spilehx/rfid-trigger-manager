#!/usr/bin/env bash
set -euo pipefail

# Log everything from here on
exec >> "$HOME/.rfid-autostart.log" 2>&1
echo "===== $(date) start ====="

# Make sure PATH is sane in GUI session
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Run from the script’s directory
cd "$(dirname "$0")"
echo "PWD: $(pwd)"

# Where is 'hl'?
echo "command -v hl -> $(command -v hl || echo 'NOT FOUND')"

# Run the app (stderr/stdout already go to the log via exec)
# Use absolute path to hl if command -v shows NOT FOUND, e.g. /usr/local/bin/hl
hl RFIDTriggerServer.hl </dev/null &

echo "Started hl in background with PID $!"
echo "===== $(date) end (launcher) ====="
