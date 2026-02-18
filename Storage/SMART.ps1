# SMART.ps1
# Performs a deeper SMART scan and sets global warning flags

function Invoke-SMARTDeepScan {

    Write-Host "Running SMART deep scan..." -ForegroundColor Cyan
    Write-Log -Message "SMART deep scan started."

    # Reset state
    $Global:SMARTWarning = $false

    try {
        $Disks = Get-PhysicalDisk -ErrorAction SilentlyContinue

        if (-not $Disks) {
            Write-Host "Unable to query physical disks for SMART data." -ForegroundColor Yellow
            Write-Log -Message "SMART query failed."
            return "Unknown"
        }

        foreach ($Disk in $Disks) {

            $Model  = $Disk.FriendlyName
            $Health = $Disk.HealthStatus
            $Media  = $Disk.MediaType
            $Usage  = $Disk.Usage
            $Wear   = $Disk.Wear
            $Serial = $Disk.SerialNumber

            Write-Log -Message "SMART: $Model | Media: $Media | Health: $Health | Wear: $Wear | Usage: $Usage | Serial: $Serial"

            # Health issues
            if ($Health -ne "Healthy") {
                $Global:SMARTWarning = $true
                Write-Host "SMART health issue: $Model ($Health)" -ForegroundColor Yellow
            }

            # Wear level issues (if available)
            if ($Wear -and $Wear -gt 80) {
                $Global:SMARTWarning = $true
                Write-Host "SSD wear level high: $Model ($Wear%)" -ForegroundColor Yellow
                Write-Log -Message "SSD wear high: $Model ($Wear%)"
            }
        }

        Write-Log -Message "SMART deep scan completed. Warning=$Global:SMARTWarning"

        if ($Global:SMARTWarning) {
            return "Warning"
        }
        else {
            return "Healthy"
        }
    }
    catch {
        Write-Host "SMART deep scan failed: $_" -ForegroundColor Red
        Write-Log -Message "SMART deep scan error: $_"
        return "Error"
    }
}
