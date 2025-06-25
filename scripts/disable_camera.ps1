Write-Host "Searching for camera devices..." -ForegroundColor Yellow

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
    exit 1
}

Write-Host "Found $($cameras.Count) camera device(s):" -ForegroundColor Green

$disabledCount = 0
foreach ($camera in $cameras) {
    Write-Host "Processing: $($camera.FriendlyName) (Status: $($camera.Status))" -ForegroundColor Cyan
    
    if ($camera.Status -eq "OK") {
        try {
            $camera | Disable-PnpDevice -Confirm:$false
            Write-Host "Successfully disabled: $($camera.FriendlyName)" -ForegroundColor Green
            $disabledCount++
        }
        catch {
            Write-Host "Failed to disable: $($camera.FriendlyName) - $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Already disabled or not available: $($camera.FriendlyName)" -ForegroundColor Yellow
    }
}

Write-Host "Summary: Disabled $disabledCount camera device(s)" -ForegroundColor Green
