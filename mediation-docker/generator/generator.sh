#!/bin/bash

CONFIG_FILE=$1

if [ -z "$CONFIG_FILE" ]; then
    echo "Usage: ./generator.sh <config_file>"
    exit 1
fi

source "$CONFIG_FILE"

# ── FTP config (injected via environment variables) ───────────────
FTP_HOST="${FTP_HOST:-ftp-server}"
FTP_PORT="${FTP_PORT:-21}"
FTP_USER="${FTP_USER:-mediuser}"
FTP_PASS="${FTP_PASS:-medipass}"
FTP_DIR="${FTP_DIR:-/upstream/${node}-node/cdr-files}"

cleanup() {
    echo ""
    echo "[INFO] Stopping generator for $node... Goodbye!"
    exit 0
}
trap cleanup SIGINT SIGTERM

# ── Wait for FTP server to be ready ──────────────────────────────
echo "[INFO] Waiting for FTP server at $FTP_HOST:$FTP_PORT ..."
until curl -s --connect-timeout 3 "ftp://$FTP_HOST:$FTP_PORT" \
      --user "$FTP_USER:$FTP_PASS" > /dev/null 2>&1; do
    echo "[INFO] FTP not ready yet — retrying in 3s..."
    sleep 3
done
echo "[INFO] FTP server is ready."

# ── Create remote directory ───────────────────────────────────────
curl -s --ftp-create-dirs \
     "ftp://$FTP_HOST:$FTP_PORT$FTP_DIR/" \
     --user "$FTP_USER:$FTP_PASS" > /dev/null 2>&1

echo "[INFO] Starting generator for $node ($format) → FTP:$FTP_DIR"

while true; do
    FILE_NAME="${node}_cdr_$(date +%Y%m%d_%H%M%S).txt"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    TMP="/tmp/$FILE_NAME"

    if [ "$format" == "voice" ]; then
        caller_id=$((2010000000 + RANDOM))
        receiver_id=$((2010000000 + RANDOM))
        duration=$((RANDOM % 300))
        service_id=$((RANDOM % 3 + 1))
        external_charges=$(awk 'BEGIN {printf "%.2f", rand()*10}')
        cat <<CDREOF > "$TMP"
file_id=1
caller_id=$caller_id
receiver_id=$receiver_id
start_time=$TIMESTAMP
duration=$duration
service_id=$service_id
hplmn=60201
vplmn=60202
external_charges=$external_charges
rated_flag=false
CDREOF

    elif [ "$format" == "sms" ]; then
        sender_id=$((2010000000 + RANDOM))
        receiver_id=$((2010000000 + RANDOM))
        message_length=$((RANDOM % 160))
        cat <<CDREOF > "$TMP"
file_id=2
sender_id=$sender_id
receiver_id=$receiver_id
timestamp=$TIMESTAMP
message_length=$message_length
service_type=SMS
hplmn=60201
vplmn=60202
external_charges=0.10
rated_flag=false
CDREOF

    elif [ "$format" == "data" ]; then
        imsi=60201$((RANDOM * RANDOM))
        session_duration=$((RANDOM % 600))
        data_usage_mb=$(awk 'BEGIN {printf "%.2f", rand()*500}')
        external_charges=$(awk 'BEGIN {printf "%.2f", rand()*20}')
        cat <<CDREOF > "$TMP"
file_id=3
imsi=$imsi
session_start=$TIMESTAMP
session_duration=$session_duration
data_usage_mb=$data_usage_mb
apn=internet
hplmn=60201
vplmn=60202
external_charges=$external_charges
rated_flag=false
CDREOF
    fi

    # ── Upload to FTP ─────────────────────────────────────────────
    curl -s -T "$TMP" \
         "ftp://$FTP_HOST:$FTP_PORT$FTP_DIR/$FILE_NAME" \
         --user "$FTP_USER:$FTP_PASS" \
         --ftp-create-dirs

    if [ $? -eq 0 ]; then
        echo "[$node] Uploaded → $FTP_DIR/$FILE_NAME"
    else
        echo "[$node] ❌ FTP upload failed: $FILE_NAME"
    fi

    rm -f "$TMP"
    sleep 10
done
