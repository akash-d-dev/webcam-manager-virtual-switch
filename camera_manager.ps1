Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Camera Manager"
$form.Size = New-Object System.Drawing.Size(500, 480)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Create title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Webcam Control Panel"
$titleLabel.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(150, 20)
$titleLabel.Size = New-Object System.Drawing.Size(200, 30)
$titleLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($titleLabel)

# Create list box for cameras
$cameraListBox = New-Object System.Windows.Forms.ListBox
$cameraListBox.Location = New-Object System.Drawing.Point(20, 70)
$cameraListBox.Size = New-Object System.Drawing.Size(460, 200)
$cameraListBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$form.Controls.Add($cameraListBox)

# Create status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready"
$statusLabel.Location = New-Object System.Drawing.Point(20, 280)
$statusLabel.Size = New-Object System.Drawing.Size(460, 20)
$statusLabel.Font = New-Object System.Drawing.Font("Arial", 10)
$form.Controls.Add($statusLabel)

# Create buttons
$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Text = "Refresh Cameras"
$refreshButton.Location = New-Object System.Drawing.Point(20, 310)
$refreshButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($refreshButton)

$disableButton = New-Object System.Windows.Forms.Button
$disableButton.Text = "Disable Selected"
$disableButton.Location = New-Object System.Drawing.Point(150, 310)
$disableButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($disableButton)

$enableButton = New-Object System.Windows.Forms.Button
$enableButton.Text = "Enable Selected"
$enableButton.Location = New-Object System.Drawing.Point(280, 310)
$enableButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($enableButton)

$disableAllButton = New-Object System.Windows.Forms.Button
$disableAllButton.Text = "Disable All"
$disableAllButton.Location = New-Object System.Drawing.Point(20, 360)
$disableAllButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($disableAllButton)

$enableAllButton = New-Object System.Windows.Forms.Button
$enableAllButton.Text = "Enable All"
$enableAllButton.Location = New-Object System.Drawing.Point(150, 360)
$enableAllButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($enableAllButton)

# Function to refresh camera list
function Refresh-CameraList {
    $cameraListBox.Items.Clear()
    $statusLabel.Text = "Scanning for cameras..."
    $form.Refresh()
    
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
            $status = if ($camera.Status -eq "OK") { "Enabled" } else { "Disabled" }
            $cameraListBox.Items.Add("$status | $($camera.FriendlyName)")
        }
        $statusLabel.Text = "Found $($cameras.Count) camera device(s)"
    } else {
        $cameraListBox.Items.Add("No camera devices found")
        $statusLabel.Text = "No cameras detected"
    }
}

# Button event handlers
$refreshButton.Add_Click({ Refresh-CameraList })

$disableButton.Add_Click({
    if ($cameraListBox.SelectedIndex -ge 0) {
        $selectedText = $cameraListBox.SelectedItem.ToString()
        if ($selectedText -like "*Enabled*") {
            $cameraName = $selectedText.Split("|")[1].Trim()
            $cameras = Get-PnpDevice | Where-Object { $_.FriendlyName -eq $cameraName }
            foreach ($camera in $cameras) {
                try {
                    $camera | Disable-PnpDevice -Confirm:$false
                    $statusLabel.Text = "Disabled: $cameraName"
                } catch {
                    $statusLabel.Text = "Failed to disable: $($_.Exception.Message)"
                }
            }
            Refresh-CameraList
        } else {
            $statusLabel.Text = "Camera is already disabled"
        }
    } else {
        $statusLabel.Text = "Please select a camera first"
    }
})

$enableButton.Add_Click({
    if ($cameraListBox.SelectedIndex -ge 0) {
        $selectedText = $cameraListBox.SelectedItem.ToString()
        if ($selectedText -like "*Disabled*") {
            $cameraName = $selectedText.Split("|")[1].Trim()
            $cameras = Get-PnpDevice | Where-Object { $_.FriendlyName -eq $cameraName }
            foreach ($camera in $cameras) {
                try {
                    $camera | Enable-PnpDevice -Confirm:$false
                    $statusLabel.Text = "Enabled: $cameraName"
                } catch {
                    $statusLabel.Text = "Failed to enable: $($_.Exception.Message)"
                }
            }
            Refresh-CameraList
        } else {
            $statusLabel.Text = "Camera is already enabled"
        }
    } else {
        $statusLabel.Text = "Please select a camera first"
    }
})

$disableAllButton.Add_Click({
    $cameras = Get-PnpDevice | Where-Object { 
        $_.Class -eq "Camera" -or 
        $_.Class -eq "Image" -or 
        $_.FriendlyName -like "*camera*" -or 
        $_.FriendlyName -like "*webcam*" -or
        $_.FriendlyName -like "*UVC*" -or
        $_.FriendlyName -like "*USB*" -and ($_.FriendlyName -like "*camera*" -or $_.FriendlyName -like "*webcam*" -or $_.FriendlyName -like "*UVC*")
    }
    
    $disabledCount = 0
    foreach ($camera in $cameras) {
        if ($camera.Status -eq "OK") {
            try {
                $camera | Disable-PnpDevice -Confirm:$false
                $disabledCount++
            } catch {
                # Continue with other cameras
            }
        }
    }
    $statusLabel.Text = "Disabled $disabledCount camera(s)"
    Refresh-CameraList
})

$enableAllButton.Add_Click({
    $cameras = Get-PnpDevice | Where-Object { 
        $_.Class -eq "Camera" -or 
        $_.Class -eq "Image" -or 
        $_.FriendlyName -like "*camera*" -or 
        $_.FriendlyName -like "*webcam*" -or
        $_.FriendlyName -like "*UVC*" -or
        $_.FriendlyName -like "*USB*" -and ($_.FriendlyName -like "*camera*" -or $_.FriendlyName -like "*webcam*" -or $_.FriendlyName -like "*UVC*")
    }
    
    $enabledCount = 0
    foreach ($camera in $cameras) {
        if ($camera.Status -eq "Error") {
            try {
                $camera | Enable-PnpDevice -Confirm:$false
                $enabledCount++
            } catch {
                # Continue with other cameras
            }
        }
    }
    $statusLabel.Text = "Enabled $enabledCount camera(s)"
    Refresh-CameraList
})

# Initial load
Refresh-CameraList

# Show the form
$form.ShowDialog() 