# SSDHealth.ps1
# Performs SSD health checks and sets global health flags

function Invoke-SSDHealthCheck {

    Write-Host "Checking SSD health..." -ForegroundColor Cyan
    Write-Log -Message "SSD health check started."

    $Global:SSDHealthWarning = $false

    try {
        $Disks = Get-PhysicalDisk -ErrorAction SilentlyContinue

        if (-not $Disks) {
            Write-Host "Unable to query physical disks." -ForegroundColor Yellow
            Write-Log -Message "Physical disk query failed."
            return "Unknown"
        }

        foreach ($Disk in $Disks) {

            $Model  = $Disk.FriendlyName
            $Health = $Disk.HealthStatus
            $Media  = $Disk.MediaType

            Write-Log -Message "Disk detected: $Model ($Media) - Health: $Health"

            if ($Media -eq "SSD") {

                if ($Health -ne "Healthy") {
                    $Global:SSDHealthWarning = $true
                    Write-Host "SSD health issue detected: $Model ($Health)" -ForegroundColor Yellow
                    Write-Log -Message "SSD health issue: $Model ($Health)"
                }
                else {
                    Write-Host "SSD OK: $Model" -ForegroundColor Green
                }
            }
        }

        Write-Log -Message "SSD health check completed. Warning=$Global:SSDHealthWarning"

        if ($Global:SSDHealthWarning) {
            return "Warning"
        }
        else {
            return "Healthy"
        }
    }
    catch {
        Write-Host "SSD health check failed: $_" -ForegroundColor Red
        Write-Log -Message "SSD health check error: $_"
        return "Error"
    }
}
