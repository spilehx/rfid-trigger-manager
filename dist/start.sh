#!/usr/bin/env bash
set -euo pipefail

# Run from the script’s directory
cd "$(dirname "$0")"

# Let systemd track the real process (no '&', no nohup)
# Send logs to journald; remove the redirections if you want to see logs
# in 'journalctl -u cassette.service'.
exec /usr/bin/env hl RFIDTriggerServer.hl
