# Check camera status script
# Returns 0 if cameras are enabled, 1 if disabled, 2 if no cameras found

Write-Host "Checking camera device status..." -ForegroundColor Yellow

# Find all camera devices
$cameras = Get-PnpDevice | Where-Object { 
    $_.Class -eq "Camera" -or 
    $_.Class -eq "Image" -or 
    $_.FriendlyName -like "*camera*" -or 
    $_.FriendlyName -like "*webcam*" -or
    $_.FriendlyName -like "*UVC*" -or
    $_.FriendlyName -like "*USB*" -and ($_.FriendlyName -like "*camera*" -or $_.FriendlyName -like "*webcam*" -or $_.FriendlyName -like "*UVC*")
}

if (-not $cameras) {
    Write-Host "No camera devices found!" -ForegroundColor Red
    exit 2
}

Write-Host "Found $($cameras.Count) camera device(s):" -ForegroundColor Green

$enabledCount = 0
$disabledCount = 0

foreach ($camera in $cameras) {
    $status = $camera.Status
    $color = if ($status -eq "OK") { "Green" } else { "Red" }
    Write-Host "  $($camera.FriendlyName): $status" -ForegroundColor $color
    
    if ($status -eq "OK") {
        $enabledCount++
    } else {
        $disabledCount++
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Enabled cameras: $enabledCount" -ForegroundColor Green
Write-Host "  Disabled cameras: $disabledCount" -ForegroundColor Red

# Return exit code based on status
if ($enabledCount -gt 0) {
    Write-Host "`nCameras are ENABLED" -ForegroundColor Green
    exit 0  # Cameras are enabled
} else {
    Write-Host "`nCameras are DISABLED" -ForegroundColor Red
    exit 1  # Cameras are disabled
} 