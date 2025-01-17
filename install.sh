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

# Generate UUID
UUID=$(python3 -c 'import uuid; print(str(uuid.uuid4()))')

# Create new configuration
cat > "$CONFIG_PATH" << EOF
{
    "telemetry.machineId": "$UUID",
    "telemetry.macMachineId": "$UUID",
    "telemetry.devDeviceId": "$UUID",
    "telemetry.sqmId": "$UUID"
}
EOF

echo "Instalasi selesai! Silakan buka kembali Cursor." 