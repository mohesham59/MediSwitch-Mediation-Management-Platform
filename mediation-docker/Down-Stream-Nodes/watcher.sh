# Down-Stream-Nodes/watcher.sh
#!/bin/bash

CONFIG_FILE=$1

if [ -z "$CONFIG_FILE" ]; then
    echo "Usage: ./watcher.sh <config_file>"
    exit 1
fi

source "$CONFIG_FILE"

mkdir -p "$input"

cleanup() {
    echo ""
    echo "[INFO] Stopping watcher for $node... Goodbye!"
    exit 0
}

trap cleanup SIGINT SIGTERM

echo "[INFO] Starting watcher for $node - watching $input"

SEEN_FILES=""

while true; do
    for FILE in "$input"/*.txt; do
        [ -e "$FILE" ] || continue
        BASENAME=$(basename "$FILE")
        if [[ "$SEEN_FILES" != *"$BASENAME"* ]]; then
            echo "[$node] Received: $BASENAME"
            SEEN_FILES="$SEEN_FILES $BASENAME"
        fi
    done
    sleep 5
done