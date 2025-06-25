Write-Host "Available Camera Devices:" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

$cameras = Get-PnpDevice | Where-Object { 
    $_.Class -eq "Camera" -or 
    $_.Class -eq "Image" -or 
    $_.FriendlyName -like "*camera*" -or 
    $_.FriendlyName -like "*webcam*" -or
    $_.FriendlyName -like "*UVC*" -or
    $_.FriendlyName -like "*USB*" -and ($_.FriendlyName -like "*camera*" -or $_.FriendlyName -like "*webcam*" -or $_.FriendlyName -like "*UVC*")
}

if ($cameras) {
    foreach ($camera in $cameras) {
        Write-Host "Name: $($camera.FriendlyName)" -ForegroundColor Yellow
        Write-Host "Status: $($camera.Status)" -ForegroundColor Cyan
        Write-Host "Instance ID: $($camera.InstanceId)" -ForegroundColor Gray
        Write-Host "---"
    }
} else {
    Write-Host "No camera devices found!" -ForegroundColor Red
}

Write-Host "`nAll PnP Devices (for reference):" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*camera*" -or $_.FriendlyName -like "*webcam*" -or $_.FriendlyName -like "*UVC*" } | Format-Table FriendlyName, Status, InstanceId 