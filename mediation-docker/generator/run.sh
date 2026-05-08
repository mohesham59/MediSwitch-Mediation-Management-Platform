#!/bin/bash

NODE=$1

if [ -z "$NODE" ]; then
    echo "Usage: ./run.sh <node>"
    echo "Example: ./run.sh msc"
    exit 1
fi

CONFIG="./configs/${NODE}.conf"

if [ ! -f "$CONFIG" ]; then
    echo "Config not found: $CONFIG"
    exit 1
fi

./generator.sh "$CONFIG"