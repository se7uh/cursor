# Stop Cursor process if running
Get-Process cursor -ErrorAction SilentlyContinue | Stop-Process -Force

# Path to storage.json
$configPath = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

# Create backup
if (Test-Path $configPath) {
    Copy-Item $configPath "$configPath.backup"
}

# Generate new configuration
$uuid = [guid]::NewGuid().ToString()
$config = @{
    "telemetry.machineId" = $uuid
    "telemetry.macMachineId" = $uuid
    "telemetry.devDeviceId" = $uuid
    "telemetry.sqmId" = $uuid
}

# Create directory if it doesn't exist
$directory = Split-Path $configPath -Parent
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force
}

# Save configuration
$config | ConvertTo-Json | Set-Content $configPath

Write-Host "Instalasi selesai! Silakan buka kembali Cursor." 