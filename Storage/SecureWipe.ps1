# SecureWipe.ps1
# Securely wipes free space on a selected NON-SYSTEM drive.
# This module NEVER runs automatically. User must explicitly call it.

function Invoke-SecureWipe {

    Write-Host "Secure Wipe Utility" -ForegroundColor Cyan
    Write-Log -Message "Secure wipe invoked."

    # ---------------------------------------------------------
    # Enumerate drives (excluding system drive)
    # ---------------------------------------------------------
    $Drives = Get-PSDrive -PSProvider FileSystem | Where-Object {
        $_.Root -ne $env:SystemDrive
    }

    if (-not $Drives) {
        Write-Host "No eligible drives found for secure wipe." -ForegroundColor Yellow
        Write-Log -Message "No eligible drives found."
        return "NoDrives"
    }

    Write-Host ""
    Write-Host "Available drives for secure wipe:" -ForegroundColor Yellow
    foreach ($D in $Drives) {
        Write-Host " - $($D.Name): $($D.Root)"
    }

    # ---------------------------------------------------------
    # Ask user to choose a drive
    # ---------------------------------------------------------
    $DriveLetter = Read-Host "Enter the drive letter you want to wipe (e.g., D)"

    if (-not ($Drives.Name -contains $DriveLetter)) {
        Write-Host "Invalid drive selection." -ForegroundColor Red
        Write-Log -Message "Invalid drive selection: $DriveLetter"
        return "InvalidSelection"
    }

    $Target = ($Drives | Where-Object { $_.Name -eq $DriveLetter }).Root

    Write-Host ""
    Write-Host "WARNING: This will securely wipe FREE SPACE on drive $Target" -ForegroundColor Yellow
    Write-Host "It will NOT delete files, but it will overwrite deleted data." -ForegroundColor Yellow
    Write-Host ""

    # ---------------------------------------------------------
    # Explicit confirmation
    # ---------------------------------------------------------
    $Confirm = Read-Host "Type WIPE to continue"

    if ($Confirm -ne "WIPE") {
        Write-Host "Operation cancelled." -ForegroundColor Cyan
        Write-Log -Message "Secure wipe cancelled by user."
        return "Cancelled"
    }

    # ---------------------------------------------------------
    # Perform wipe using cipher /w:
    # ---------------------------------------------------------
    try {
        Write-Host "Wiping free space on $Target ..." -ForegroundColor Cyan
        Write-Log -Message "Secure wipe started on $Target"

        cipher /w:$Target | Out-Null

        Write-Host "Secure wipe completed." -ForegroundColor Green
        Write-Log -Message "Secure wipe completed on $Target"

        return "Success"
    }
    catch {
        Write-Host "Secure wipe failed: $_" -ForegroundColor Red
        Write-Log -Message "Secure wipe error: $_"
        return "Error"
    }
}
