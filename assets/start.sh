mkdir -p /home/cassette/bin

cat > /home/cassette/bin/rfid-autostart.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# 1) Log immediately so we KNOW this ran
exec >> "$HOME/.rfid-autostart.log" 2>&1
echo "===== $(date) start (wrapper) ====="

# 2) Sane PATH for GUI sessions
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# 3) Go to app dir
cd "/home/cassette/rfid-trigger-manager/dist" || { echo "cd failed"; exit 1; }
echo "PWD: $(pwd)"

# 4) Locate 'hl' (and print the path we’ll use)
HL_BIN="$(command -v hl || true)"
if [[ -z "${HL_BIN}" ]]; then
  # try common location
  for p in /usr/local/bin/hl /usr/bin/hl; do
    [[ -x "$p" ]] && HL_BIN="$p" && break
  done
fi
echo "HL_BIN='$HL_BIN'"

if [[ -z "${HL_BIN}" ]]; then
  echo "ERROR: 'hl' not found in PATH. Install it or set absolute path."
  exit 127
fi

# 5) Make sure the .hl file exists
[[ -f RFIDTriggerServer.hl ]] || { echo "ERROR: RFIDTriggerServer.hl missing"; exit 1; }

# 6) Start in background so autostart can exit cleanly
nohup "$HL_BIN" RFIDTriggerServer.hl </dev/null &

echo "Started hl with PID $!"
echo "===== $(date) end (wrapper) ====="
EOF

chmod +x /home/cassette/bin/rfid-autostart.sh
