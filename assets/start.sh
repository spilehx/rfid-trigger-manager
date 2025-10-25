cat > /home/cassette/rfid-trigger-manager/dist/start.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Log everything from here on
exec >> "$HOME/.rfid-autostart.log" 2>&1
echo "===== $(date) start ====="

# Sane PATH in GUI sessions
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Run from the script’s directory
cd "$(dirname "$0")"
echo "PWD: $(pwd)"

# Show where 'hl' is (or NOT FOUND)
echo "command -v hl -> $(command -v hl || echo 'NOT FOUND')"

# Start your app in background so launcher can exit cleanly
# If NOT FOUND above, change 'hl' to its absolute path (e.g. /usr/local/bin/hl)
nohup hl RFIDTriggerServer.hl </dev/null &

echo "Started hl with PID $!"
echo "===== $(date) end (launcher) ====="
EOF

chmod +x /home/cassette/rfid-trigger-manager/dist/start.sh
