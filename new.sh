#!/bin/bash

# Version information
VERSION="v1.0.1"
CURSOR_VERSION_MAX="v0.45.x"
AUTHOR="se7uh"
REPO="https://github.com/se7uh/cursor"

# Color codes
GOLD="\e[38;5;220m"
SILVER="\e[38;5;247m"
BLUE="\e[38;5;39m"
PURPLE="\e[38;5;171m"
GREEN="\e[38;5;82m"
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"

# Variables
FAKE_ID_FILE="$HOME/.fake_machine_id"
REAL_ID_FILE="/var/lib/dbus/machine-id"
MOUNTED_FILE="/proc/mounts"
CONFIG_PATH="$HOME/.config/Cursor/User/globalStorage/storage.json"

# Function to print fancy box
function print_fancy_box() {
    local text="$1"
    local stripped_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local length=${#stripped_text}
    local total_width=50
    local padding=$((total_width - length))
    local left_pad=$((padding / 2))
    local right_pad=$((padding - left_pad))
    
    echo -e "${GOLD}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${GOLD}║${RESET}$(printf '%*s' $left_pad)$text$(printf '%*s' $right_pad)${GOLD}║${RESET}"
    echo -e "${GOLD}╚══════════════════════════════════════════════════╝${RESET}"
}

# Function to show version and info
function show_version() {
    clear
    print_fancy_box " ${BOLD}${PURPLE}Cursor Hack ${GOLD}$VERSION ${RESET}"
    echo
    echo -e "${BLUE}${BOLD}System Information:${RESET}"
    echo -e "${SILVER}├─ Compatible: ${GREEN}Cursor $CURSOR_VERSION_MAX${RESET}"
    echo -e "${SILVER}├─ Author: ${PURPLE}$AUTHOR${RESET}"
    echo -e "${SILVER}└─ Repository: ${BLUE}$REPO ${DIM}(Private)${RESET}"
}

# Function to generate a new fake machine ID
function generate_fake_id() {
    echo "$(uuidgen | md5sum | awk '{print $1}')" > "$FAKE_ID_FILE" && \
    print_success "New fake machine ID generated: ${BLUE}$(cat $FAKE_ID_FILE)${RESET}"
}

# Function to turn on the fake machine ID
function turn_on() {
    if mountpoint -q "$REAL_ID_FILE"; then
        print_info "Fake machine ID is already active."
    else
        if [ ! -f "$FAKE_ID_FILE" ]; then
            generate_fake_id
        fi
        sudo mount --bind "$FAKE_ID_FILE" "$REAL_ID_FILE" && print_success "Fake machine ID activated."
    fi
}

# Function to turn off the fake machine ID
function turn_off() {
    if mountpoint -q "$REAL_ID_FILE"; then
        sudo umount "$REAL_ID_FILE" && print_success "Fake machine ID deactivated."
    else
        print_info "Fake machine ID is not active."
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
    clear
    print_fancy_box " ${BOLD}${PURPLE}Cursor Hack ${GOLD}$VERSION ${RESET}"
    echo
    echo -e "${BLUE}${BOLD}Available Commands:${RESET}"
    echo -e "${SILVER}├─ ${GOLD}on      ${RESET}- Activate fake machine ID"
    echo -e "${SILVER}├─ ${GOLD}off     ${RESET}- Deactivate fake machine ID"
    echo -e "${SILVER}├─ ${GOLD}new     ${RESET}- Generate a new fake machine ID"
    echo -e "${SILVER}├─ ${GOLD}gen     ${RESET}- Generate new telemetry data"
    echo -e "${SILVER}├─ ${GOLD}run     ${RESET}- Run the application with fake machine ID"
    echo -e "${SILVER}└─ ${GOLD}version ${RESET}- Show version information"
}

# Success message function
function print_success() {
    echo -e "${GREEN}${BOLD}✓ $1${RESET}"
}

# Error message function
function print_error() {
    echo -e "\e[91m${BOLD}✗ $1${RESET}"
}

# Info message function
function print_info() {
    echo -e "${BLUE}${BOLD}ℹ $1${RESET}"
}

# Main logic to handle command-line arguments
case "$1" in
    on) turn_on ;;
    off) turn_off ;;
    new) generate_fake_id ;;
    gen) generate_new_id ;;  # Generate new telemetry data and update JSON
    run) run_application "$2" ;;  # Run the application with fake machine ID
    version) show_version ;;  # Show version information
    *) show_help ;;
esac
