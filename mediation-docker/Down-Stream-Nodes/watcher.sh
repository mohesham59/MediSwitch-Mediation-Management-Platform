#!/bin/bash

CONFIG_FILE=$1

if [ -z "$CONFIG_FILE" ]; then
    echo "Usage: ./watcher.sh <config_file>"
    exit 1
fi

source "$CONFIG_FILE"

# ── FTP config ────────────────────────────────────────────────────
FTP_HOST="${FTP_HOST:-ftp-server}"
FTP_PORT="${FTP_PORT:-21}"
FTP_USER="${FTP_USER:-mediuser}"
FTP_PASS="${FTP_PASS:-medipass}"
# downstream FTP directory for this node
FTP_DIR="${FTP_DIR:-/downstream/${node}-node/cdr-files}"

cleanup() {
    echo ""
    echo "[INFO] Stopping watcher for $node... Goodbye!"
    exit 0
}
trap cleanup SIGINT SIGTERM

# ── Wait for FTP ──────────────────────────────────────────────────
echo "[INFO] Waiting for FTP server..."
until curl -s --connect-timeout 3 "ftp://$FTP_HOST:$FTP_PORT" \
      --user "$FTP_USER:$FTP_PASS" > /dev/null 2>&1; do
    sleep 3
done

echo "[INFO] Starting watcher for $node - watching FTP:$FTP_DIR"

SEEN_FILES=""

while true; do
    # List files on FTP
    FILE_LIST=$(curl -s --list-only \
        "ftp://$FTP_HOST:$FTP_PORT$FTP_DIR/" \
        --user "$FTP_USER:$FTP_PASS" 2>/dev/null)

    while IFS= read -r BASENAME; do
        [ -z "$BASENAME" ] && continue
        # Only process CSV files written by mediation engine
        [[ "$BASENAME" != *.csv ]] && continue

        if [[ "$SEEN_FILES" != *"$BASENAME"* ]]; then
            echo "[$node] Received: $BASENAME"
            SEEN_FILES="$SEEN_FILES $BASENAME"
        fi
    done <<< "$FILE_LIST"

    sleep 5
done
