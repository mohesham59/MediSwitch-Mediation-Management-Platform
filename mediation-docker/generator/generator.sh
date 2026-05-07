#!/bin/bash

CONFIG_FILE=$1

if [ -z "$CONFIG_FILE" ]; then
    echo "Usage: ./generator.sh <config_file>"
    exit 1
fi

source "$CONFIG_FILE"

mkdir -p "$output"

# Trap Ctrl+C (SIGINT) and SIGTERM
cleanup() {
    echo ""
    echo "[INFO] Stopping generator for $node... Goodbye!"
    exit 0
}

trap cleanup SIGINT SIGTERM

echo "[INFO] Starting generator for $node ($format)"

while true
do
    FILE_NAME="${node}_cdr_$(date +%Y%m%d_%H%M%S).txt"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ "$format" == "voice" ]; then

        caller_id=$((2010000000 + RANDOM))
        receiver_id=$((2010000000 + RANDOM))
        duration=$((RANDOM % 300))
        service_id=$((RANDOM % 3 + 1))
        hplmn=60201
        vplmn=60202
        external_charges=$(awk 'BEGIN {printf "%.2f", rand()*10}')
        rated_flag=false

        cat <<EOF > "$output/$FILE_NAME"
file_id=1
caller_id=$caller_id
receiver_id=$receiver_id
start_time=$TIMESTAMP
duration=$duration
service_id=$service_id
hplmn=$hplmn
vplmn=$vplmn
external_charges=$external_charges
rated_flag=$rated_flag
EOF

    elif [ "$format" == "sms" ]; then

        sender_id=$((2010000000 + RANDOM))
        receiver_id=$((2010000000 + RANDOM))
        message_length=$((RANDOM % 160))
        external_charges=0.10

        cat <<EOF > "$output/$FILE_NAME"
file_id=2
sender_id=$sender_id
receiver_id=$receiver_id
timestamp=$TIMESTAMP
message_length=$message_length
service_type=SMS
hplmn=60201
vplmn=60202
external_charges=$external_charges
rated_flag=false
EOF

    elif [ "$format" == "data" ]; then

        imsi=60201$((RANDOM * RANDOM))
        session_duration=$((RANDOM % 600))
        data_usage_mb=$(awk 'BEGIN {printf "%.2f", rand()*500}')
        external_charges=$(awk 'BEGIN {printf "%.2f", rand()*20}')

        cat <<EOF > "$output/$FILE_NAME"
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
EOF
    fi

    echo "[$node] Generated $FILE_NAME"

    sleep 10
done