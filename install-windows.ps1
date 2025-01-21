# Stop Cursor process if running
Get-Process cursor -ErrorAction SilentlyContinue | Stop-Process -Force

# Path to storage.json
$configPath = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

# Create backup
if (Test-Path $configPath) {
    Copy-Item $configPath "$configPath.backup"
}

# Read existing config or create new one if doesn't exist
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
} else {
    $config = @{}
}

# Generate UUID using PowerShell
$uuid = [guid]::NewGuid().ToString()

# Update only the required properties
$config.'telemetry.machineId' = $uuid
$config.'telemetry.macMachineId' = $uuid
$config.'telemetry.devDeviceId' = $uuid
$config.'telemetry.sqmId' = $uuid

# Create directory if it doesn't exist
$directory = Split-Path $configPath -Parent
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force
}

# Save configuration
$config | ConvertTo-Json | Set-Content $configPath

Write-Host "Instalasi selesai! Silakan buka kembali Cursor." 