# Camera Manager

A Windows utility for managing webcam devices with administrator privileges.

## Features

- **Camera Manager GUI**: Full graphical interface for camera management
- **Quick Toggle**: One-click camera enable/disable toggle
- **Individual Control**: Enable or disable specific cameras
- **Batch Operations**: Enable or disable all cameras at once
- **Status Monitoring**: Check camera status and list all devices

## Files

### Main Scripts
- `camera_manager.bat` - Launches the graphical camera manager interface
- `toggle_camera.bat` - Quick toggle to enable/disable all cameras

### PowerShell Scripts (in `scripts/` folder)
- `camera_manager.ps1` - Main GUI application for camera management
- `enable_camera.ps1` - Enables all camera devices
- `disable_camera.ps1` - Disables all camera devices
- `check_camera_status.ps1` - Checks and reports camera status
- `list_cameras.ps1` - Lists all camera devices

### Batch Wrappers (in `scripts/` folder)
- `enable_camera.bat` - Batch wrapper for enable script
- `disable_camera.bat` - Batch wrapper for disable script
- `list_cameras.bat` - Batch wrapper for list script

## Usage

### Quick Toggle
Double-click `toggle_camera.bat` to quickly toggle all cameras on/off.

### Full Management
Double-click `camera_manager.bat` to open the graphical interface with:
- View all camera devices
- Enable/disable individual cameras
- Enable/disable all cameras at once
- Real-time status updates

### Command Line
Run any of the batch files in the `scripts/` folder for specific operations.

## Requirements

- Windows 10/11
- Administrator privileges (automatically requested)
- PowerShell execution policy (automatically bypassed)

## How It Works

The scripts use Windows PnP (Plug and Play) device management to:
1. Detect camera devices using device classes and friendly names
2. Enable/disable devices using PowerShell cmdlets
3. Provide status feedback and error handling

## Security

- All scripts require administrator privileges for device management
- UAC elevation is handled automatically
- No permanent changes to system settings
- Safe to run multiple times

## Troubleshooting

If cameras don't appear:
- Ensure you have camera devices connected
- Check device manager for camera status
- Run as administrator if issues persist

## License

Free to use and modify for personal use. 