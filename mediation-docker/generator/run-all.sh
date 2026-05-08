#!/bin/bash

# Store background process IDs
PIDS=()

cleanup() {
    echo ""
    echo "[INFO] Stopping all generators..."
    for PID in "${PIDS[@]}"; do
        kill "$PID" 2>/dev/null
    done
    wait
    echo "[INFO] All generators stopped. Goodbye!"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start generators in background and save their PIDs
./generator.sh configs/msc.conf &
PIDS+=($!)

./generator.sh configs/pgw.conf &
PIDS+=($!)

./generator.sh configs/smsc.conf &
PIDS+=($!)

# Wait for all background processes
wait