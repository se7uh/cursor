#!/bin/bash

# Version information
VERSION="v1.0.999"
AUTHOR="se7uh"
REPO="https://github.com/se7uh/cursr"

# Color codes
GOLD="\e[38;5;220m"
SILVER="\e[38;5;247m"
BLUE="\e[38;5;39m"
PURPLE="\e[38;5;171m"
GREEN="\e[38;5;82m"
RED="\e[38;5;196m"
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"

# Unicode symbols
CHECK_MARK="✓"
CROSS_MARK="✗"
INFO_MARK="ⓘ"

# Variables
REAL_ID_FILE="/var/lib/dbus/machine-id"
MOUNTED_FILE="/proc/mounts"
CONFIG_PATH="$HOME/.config/Cursor/User/globalStorage/storage.json"
SETTINGS_FILE="$HOME/.fakem.json"

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
    print_fancy_box " ${BOLD}${PURPLE}FAKEM4🖱️ ${GOLD}$VERSION ${RESET}"
    echo
    echo -e "${BLUE}${BOLD}System Information:${RESET}"
    echo -e "${SILVER}├─ Author: ${PURPLE}$AUTHOR${RESET}"
    echo -e "${SILVER}└─ Repository: ${BLUE}$REPO ${DIM}(Private)${RESET}"
}

# Function to generate a new fake machine ID
function generate_fake_id() {
    local fake_id="$(uuidgen | md5sum | awk '{print $1}')"
    
    # Check if settings file exists, if not create it with default values
    if [ ! -f "$SETTINGS_FILE" ]; then
        create_settings "$fake_id" "$(date +%Y-%m-%d)"
    else
        # Update just the fake_id in the settings file
        update_settings "fake_id" "$fake_id"
    fi
    
    print_success "New fake machine ID generated: ${BLUE}$fake_id${RESET}"
}

# Function to generate beta format telemetry IDs
function generate_beta_id() {
    # Generate telemetry IDs using Python for beta format
    python3 -c '
import uuid
import hashlib
import os
import json

# Generate shorter beta format IDs
dev_device_id = str(uuid.uuid4())
machine_id = hashlib.sha256(os.urandom(16)).hexdigest()
mac_machine_id = hashlib.sha256(os.urandom(16)).hexdigest()
sqm_id = ""  # Empty in beta format

# Create new beta telemetry data
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

    print_success "Beta telemetry data updated in $CONFIG_PATH"
}

# Function to create or update settings
function create_settings() {
    local fake_id="$1"
    local fake_date="$2"
    
    # Create settings JSON file
    cat > "$SETTINGS_FILE" << EOF
{
    "fake_id": "$fake_id",
    "fake_date": "$fake_date"
}
EOF
    
    print_success "Settings created at $SETTINGS_FILE"
}

# Function to update a specific setting
function update_settings() {
    local setting_key="$1"
    local setting_value="$2"
    
    # If settings file doesn't exist, create it with default values
    if [ ! -f "$SETTINGS_FILE" ]; then
        create_settings "$(uuidgen | md5sum | awk '{print $1}')" "$(date +%Y-%m-%d)"
        return
    fi
    
    # Use jq to update the settings file if available
    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        jq ".$setting_key = \"$setting_value\"" "$SETTINGS_FILE" > "$temp_file" && mv "$temp_file" "$SETTINGS_FILE"
    else
        # Fallback to Python if jq is not available
        python3 -c "
import json
import sys

try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    
    settings['$setting_key'] = '$setting_value'
    
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(settings, f, indent=4)
    
    sys.exit(0)
except Exception as e:
    print(f'Error updating settings: {e}', file=sys.stderr)
    sys.exit(1)
"
    fi
    
    print_success "Updated $setting_key in settings"
}

# Function to get a setting value
function get_setting() {
    local setting_key="$1"
    local default_value="$2"
    
    # If settings file doesn't exist, create it with default values and return the default
    if [ ! -f "$SETTINGS_FILE" ]; then
        create_settings "$(uuidgen | md5sum | awk '{print $1}')" "$(date +%Y-%m-%d)"
        echo "$default_value"
        return
    fi
    
    # Use jq to read the setting if available
    if command -v jq &> /dev/null; then
        local value=$(jq -r ".$setting_key" "$SETTINGS_FILE" 2>/dev/null)
        if [ "$value" = "null" ]; then
            echo "$default_value"
        else
            echo "$value"
        fi
    else
        # Fallback to Python if jq is not available
        python3 -c "
import json
import sys

try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    
    print(settings.get('$setting_key', '$default_value'))
    sys.exit(0)
except Exception as e:
    print('$default_value')
    sys.exit(0)
"
    fi
}

# Function to turn on the fake machine ID
function turn_on() {
    if mountpoint -q "$REAL_ID_FILE"; then
        print_info "Fake machine ID is already active."
    else
        # Get fake_id from settings or generate a new one if not exists
        local fake_id=$(get_setting "fake_id" "")
        if [ -z "$fake_id" ]; then
            fake_id="$(uuidgen | md5sum | awk '{print $1}')"
            update_settings "fake_id" "$fake_id"
        fi
        
        # Create a temporary file with the fake ID and mount it
        echo "$fake_id" > /tmp/.fakem_temp_id
        sudo mount --bind /tmp/.fakem_temp_id "$REAL_ID_FILE" && print_success "Fake machine ID activated."
        rm -f /tmp/.fakem_temp_id
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

# Function to run the application with the fake machine ID and fake date
function run_application() {
    if ! mountpoint -q "$REAL_ID_FILE"; then
        echo "Fake machine ID is not active. Activating it..."
        turn_on
    fi

    # Get fake date from settings
    local fake_date=$(get_setting "fake_date" "$(date +%Y-%m-%d)")
    
    echo "Running in zsh with fake date: $fake_date..."
    sudo -u "$USER" faketime "$fake_date" zsh -i -c "$1"
}

# Function to update the script
function update_script() {
    local script_path=$(which fakem)
    if [ -z "$script_path" ]; then
        script_path="$0"
    fi
    
    echo -e "${BLUE}${BOLD}${INFO_MARK} Updating script...${RESET}"
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Download the latest version
    if curl -fsSL https://raw.githubusercontent.com/se7uh/cursr/refs/heads/main/new.sh -o "$temp_file"; then
        # Make the downloaded script executable
        chmod +x "$temp_file"
        
        # Replace the current script with the new one
        if mv "$temp_file" "$script_path"; then
            print_success "Update successful! Script updated to latest version"
            exit 0
        else
            print_error "Failed to update script. Try running with sudo: sudo fakem update"
            rm -f "$temp_file"
            exit 1
        fi
    else
        print_error "Failed to download latest version. Check your internet connection."
        rm -f "$temp_file"
        exit 1
    fi
}

# Function to reset all IDs (both machine ID and telemetry)
function reset_all_ids() {
    print_info "Resetting all machine IDs and telemetry data..."
    generate_fake_id
    generate_new_id
    print_success "All IDs have been successfully reset"
}

# Function to configure settings
function configure_settings() {
    echo
    print_fancy_box " ${BOLD}${PURPLE}FAKEM4🖱️ Settings ${RESET}"
    echo
    
    local fake_id=$(get_setting "fake_id" "$(uuidgen | md5sum | awk '{print $1}')")
    local fake_date=$(get_setting "fake_date" "$(date +%Y-%m-%d)")
    
    echo -e "${BLUE}${BOLD}Current Settings:${RESET}"
    echo -e "${SILVER}├─ ${GOLD}Fake ID:   ${BLUE}$fake_id${RESET}"
    echo -e "${SILVER}└─ ${GOLD}Fake Date: ${BLUE}$fake_date${RESET}"
    echo
    
    # Prompt for new fake date
    echo -ne "${BLUE}Enter new fake date (YYYY-MM-DD) or press Enter to keep current: ${RESET}"
    read new_date
    
    if [ ! -z "$new_date" ]; then
        # Validate date format
        if [[ $new_date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            update_settings "fake_date" "$new_date"
        else
            print_error "Invalid date format. Please use YYYY-MM-DD format."
        fi
    fi
    
    echo
    print_success "Settings updated"
}

# Help function to show usage
function show_help() {
    clear
    print_fancy_box " ${BOLD}${PURPLE}FAKEM4🖱️  ${GOLD}$VERSION ${RESET}"
    echo
    echo -e "${BLUE}${BOLD}Available Commands:${RESET}"
    echo -e "${SILVER}├─ ${GOLD}on      ${RESET}- Activate fake machine ID"
    echo -e "${SILVER}├─ ${GOLD}off     ${RESET}- Deactivate fake machine ID"
    echo -e "${SILVER}├─ ${GOLD}new     ${RESET}- Generate a new fake machine ID"
    echo -e "${SILVER}├─ ${GOLD}gen     ${RESET}- Generate new telemetry data"
    echo -e "${SILVER}├─ ${GOLD}beta    ${RESET}- Generate beta format telemetry data"
    echo -e "${SILVER}├─ ${GOLD}reset   ${RESET}- Reset all IDs (machine ID and telemetry)"
    echo -e "${SILVER}├─ ${GOLD}run     ${RESET}- Run the application with fake machine ID"
    echo -e "${SILVER}├─ ${GOLD}settings ${RESET}- Configure fake date and other settings"
    echo -e "${SILVER}├─ ${GOLD}update  ${RESET}- Update script to latest version"
    echo -e "${SILVER}└─ ${GOLD}version ${RESET}- Show version information"
}

# Success message function
function print_success() {
    echo -e "${GREEN}${BOLD}${CHECK_MARK} $1${RESET}"
}

# Error message function
function print_error() {
    echo -e "${RED}${BOLD}${CROSS_MARK} $1${RESET}"
}

# Info message function
function print_info() {
    echo -e "${BLUE}${BOLD}${INFO_MARK} $1${RESET}"
}

# Main logic to handle command-line arguments
case "$1" in
    on) turn_on ;;
    off) turn_off ;;
    new) generate_fake_id ;;
    gen) generate_new_id ;;  # Generate new telemetry data and update JSON
    beta) generate_beta_id ;; # Generate beta format telemetry data
    reset) reset_all_ids ;;  # Reset all IDs (machine ID and telemetry)
    run) run_application "$2" ;;  # Run the application with fake machine ID
    settings) configure_settings ;; # Configure fake date and other settings
    update) update_script ;;  # Update the script to the latest version
    version) show_version ;;  # Show version information
    *) show_help ;;
esac
