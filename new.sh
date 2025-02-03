#!/bin/bash

FAKE_ID_FILE="$HOME/.fake_machine_id"
REAL_ID_FILE="/var/lib/dbus/machine-id"
MOUNTED_FILE="/proc/mounts"
CONFIG_PATH="$HOME/.config/Cursor/User/globalStorage/storage.json"

# Function to generate a new fake machine ID
function generate_fake_id() {
    echo "$(uuidgen | md5sum | awk '{print $1}')" > "$FAKE_ID_FILE"
}

# Function to turn on the fake machine ID
function turn_on() {
    if mountpoint -q "$REAL_ID_FILE"; then
        echo "Fake machine ID is already active."
    else
        if [ ! -f "$FAKE_ID_FILE" ]; then
            generate_fake_id
        fi
        sudo mount --bind "$FAKE_ID_FILE" "$REAL_ID_FILE" && echo "Fake machine ID activated."
    fi
}

# Function to turn off the fake machine ID
function turn_off() {
    if mountpoint -q "$REAL_ID_FILE"; then
        sudo umount "$REAL_ID_FILE" && echo "Fake machine ID deactivated."
    else
        echo "Fake machine ID is not active."
    fi
}

# Function to generate new telemetry data using Python and update the JSON
function generate_new_id() {
    # Generate telemetry IDs using Python
    python3 -c '
import uuid
import hashlib
import os
import json

# Generate UUIDs and machine IDs
dev_device_id = str(uuid.uuid4())
machine_id = hashlib.sha256(os.urandom(32)).hexdigest()
mac_machine_id = hashlib.sha512(os.urandom(64)).hexdigest()
sqm_id = "{" + str(uuid.uuid4()).upper() + "}"

# Create new telemetry data
new_data = {
    "telemetry.devDeviceId": dev_device_id,
    "telemetry.macMachineId": mac_machine_id,
    "telemetry.machineId": machine_id,
    "telemetry.sqmId": sqm_id,
    "storage.serviceMachineId": dev_device_id,
}

# Load existing config or initialize an empty dict
config_path = "'$CONFIG_PATH'"
try:
    with open(config_path, "r") as f:
        config = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    config = {}

# Update the existing data with new telemetry data
config.update(new_data)

# Backup the existing config before updating
if os.path.exists(config_path):
    os.rename(config_path, config_path + "bak")

# Save the updated config back to the file
with open(config_path, "w") as f:
    json.dump(config, f, indent=4)

'

    echo "Telemetry data updated in $CONFIG_PATH"
}

# Function to run the application with the fake machine ID
function run_application() {
    if ! mountpoint -q "$REAL_ID_FILE"; then
        echo "Fake machine ID is not active. Activating it..."
        turn_on
    fi

    echo "Running in zsh..."
    sudo -u "$USER" zsh -i -c "$1"
}

# Help function to show usage
function show_help() {
    echo "Usage: fakem {on|off|new|gen|run}"
    echo "  on   - Activate fake machine ID"
    echo "  off  - Deactivate fake machine ID"
    echo "  new  - Generate a new fake machine ID"
    echo "  gen  - Generate new telemetry data and update storage.json"
    echo "  run  - Run the application with fake machine ID"
}

# Main logic to handle command-line arguments
case "$1" in
    on) turn_on ;;
    off) turn_off ;;
    new) generate_fake_id && echo "New fake machine ID generated: $(cat $FAKE_ID_FILE)" ;;
    gen) generate_new_id ;;  # Generate new telemetry data and update JSON
    run) run_application "$2" ;;  # Run the application with fake machine ID
    *) show_help ;;
esac
