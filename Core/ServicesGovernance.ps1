# ServicesGovernance.ps1
# Ensures critical services are running and unwanted services are stopped

function Invoke-ServicesGovernance {
    param(
        [Parameter(Mandatory=$true)]
        $ProfileSettings
    )

    Write-Host "Checking service health..." -ForegroundColor Cyan
    Write-Log -Message "Services governance started."

    $Fixed = 0
    $Issues = 0

    try {
        # ---------------------------------------------------------
        # Services that must be running
        # ---------------------------------------------------------
        $RequiredRunning = @(
            "WinDefend",      # Microsoft Defender
            "W32Time",        # Windows Time
            "EventLog"        # Event Logging
        )

        # ---------------------------------------------------------
        # Services that should be stopped
        # ---------------------------------------------------------
        $RequiredStopped = @(
            "DiagTrack",      # Telemetry
            "RetailDemo"      # Retail demo mode
        )

        # ---------------------------------------------------------
        # Check required running services
        # ---------------------------------------------------------
        foreach ($Svc in $RequiredRunning) {
            $Service = Get-Service -Name $Svc -ErrorAction SilentlyContinue

            if ($Service -and $Service.Status -eq "Running") {
                Write-Log -Message "Service OK (running): $Svc"
            }
            else {
                Write-Host "Service not running: $Svc" -ForegroundColor Yellow
                Write-Log -Message "Service not running: $Svc"
                $Issues++

                if ($ProfileSettings.Level -in @("Power","Hardcore")) {
                    try {
                        Start-Service -Name $Svc -ErrorAction SilentlyContinue
                        Write-Log -Message "Started service: $Svc"
                        $Fixed++
                    }
                    catch {
                        Write-Log -Message "Failed to start service: $Svc"
                    }
                }
            }
        }

        # ---------------------------------------------------------
        # Check required stopped services
        # ---------------------------------------------------------
        foreach ($Svc in $RequiredStopped) {
            $Service = Get-Service -Name $Svc -ErrorAction SilentlyContinue

            if ($Service -and $Service.Status -eq "Stopped") {
                Write-Log -Message "Service OK (stopped): $Svc"
            }
            else {
                Write-Host "Service should be stopped: $Svc" -ForegroundColor Yellow
                Write-Log -Message "Service should be stopped: $Svc"
                $Issues++

                if ($ProfileSettings.Level -eq "Hardcore") {
                    try {
                        Stop-Service -Name $Svc -Force -ErrorAction SilentlyContinue
                        Write-Log -Message "Stopped service: $Svc"
                        $Fixed++
                    }
                    catch {
                        Write-Log -Message "Failed to stop service: $Svc"
                    }
                }
            }
        }

        Write-Log -Message "Services governance completed. Fixed=$Fixed Issues=$Issues"

        if ($Fixed -gt 0) { return "Fixed" }
        if ($Issues -gt 0) { return "Partial" }
        return "Healthy"
    }
    catch {
        Write-Host "Services governance failed: $_" -ForegroundColor Red
        Write-Log -Message "Services governance error: $_"
        return "Error"
    }
}
