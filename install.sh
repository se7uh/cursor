#!/bin/bash

# Kill Cursor process if running
pkill -f cursor

# Determine OS and set config path
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_PATH="$HOME/Library/Application Support/Cursor/User/globalStorage/storage.json"
else
    CONFIG_PATH="$HOME/.config/Cursor/User/globalStorage/storage.json"
fi

# Create directory if it doesn't exist
mkdir -p "$(dirname "$CONFIG_PATH")"

# Create backup if file exists
if [ -f "$CONFIG_PATH" ]; then
    cp "$CONFIG_PATH" "${CONFIG_PATH}.backup"
fi

# Read existing config or create new one
if [ -f "$CONFIG_PATH" ]; then
    EXISTING_CONFIG=$(cat "$CONFIG_PATH")
else
    EXISTING_CONFIG="{}"
fi

# Update required properties while preserving others using jq
echo "$EXISTING_CONFIG" | jq \
    --arg uuid "$UUID" \
    '.["telemetry.machineId"]=$uuid | 
     .["telemetry.macMachineId"]=$uuid | 
     .["telemetry.devDeviceId"]=$uuid | 
     .["telemetry.sqmId"]=$uuid' > "$CONFIG_PATH"

echo "Instalasi selesai! Silakan buka kembali Cursor." 
