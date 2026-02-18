# Baseline.ps1
# CLEANPC Baseline Engine (Final)

$Global:BaselinePath = "C:\cleanpc\baseline.json"

# ---------------------------------------------------------
# BUILD BASELINE
# ---------------------------------------------------------
function Invoke-BaselineBuild {

    Write-Host "Building CLEANPC baseline..." -ForegroundColor Cyan
    Write-Log -Message "Baseline build started."

    try {
        $Baseline = [ordered]@{
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

            Registry = @{
                Keys = @(
                    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion",
                    "HKLM:\SYSTEM\CurrentControlSet\Services"
                )
            }

            Services = @{
                ExpectedRunning = @(
                    "WinDefend",
                    "W32Time",
                    "EventLog"
                )
                ExpectedStopped = @(
                    "DiagTrack",
                    "RetailDemo"
                )
            }

            ScheduledTasks = @{
                Expected = @(
                    "\Microsoft\Windows\Defrag\ScheduledDefrag",
                    "\Microsoft\Windows\WindowsUpdate\Scheduled Start"
                )
            }

            ComponentStore = @{
                CheckHealth = $true
            }

            Storage = @{
                CheckSSDHealth = $true
                CheckSMART     = $true
            }
        }

        $Baseline | ConvertTo-Json -Depth 5 | Set-Content -Path $Global:BaselinePath

        Write-Host "Baseline saved to $Global:BaselinePath" -ForegroundColor Green
        Write-Log -Message "Baseline build completed successfully."
    }
    catch {
        Write-Host "Baseline build failed: $_" -ForegroundColor Red
        Write-Log -Message "Baseline build error: $_"
    }
}

# ---------------------------------------------------------
# CHECK BASELINE
# ---------------------------------------------------------
function Invoke-BaselineCheck {

    Write-Host "Checking CLEANPC baseline..." -ForegroundColor Cyan
    Write-Log -Message "Baseline check started."

    $Global:DriftDetectedCount = 0

    if (-not (Test-Path $Global:BaselinePath)) {
        Write-Host "Baseline not found. Building a new one..." -ForegroundColor Yellow
        Invoke-BaselineBuild
        return
    }

    try {
        $Baseline = Get-Content -Path $Global:BaselinePath | ConvertFrom-Json

        Write-Host "Baseline loaded. Performing checks..." -ForegroundColor Green

        # ---------------------------------------------------------
        # Registry Checks
        # ---------------------------------------------------------
        foreach ($Key in $Baseline.Registry.Keys) {
            if (Test-Path $Key) {
                Write-Log -Message "Registry OK: $Key"
            }
            else {
                Write-Log -Message "Registry MISSING: $Key" -Level "WARN"
                $Global:DriftDetectedCount++
            }
        }

        # ---------------------------------------------------------
        # Service Checks
        # ---------------------------------------------------------
        foreach ($Svc in $Baseline.Services.ExpectedRunning) {
            $State = (Get-Service -Name $Svc -ErrorAction SilentlyContinue).Status
            if ($State -ne "Running") {
                Write-Log -Message "Service NOT running: $Svc" -Level "WARN"
                $Global:DriftDetectedCount++
            }
        }

        foreach ($Svc in $Baseline.Services.ExpectedStopped) {
            $State = (Get-Service -Name $Svc -ErrorAction SilentlyContinue).Status
            if ($State -ne "Stopped") {
                Write-Log -Message "Service NOT stopped: $Svc" -Level "WARN"
                $Global:DriftDetectedCount++
            }
        }

        # ---------------------------------------------------------
        # Scheduled Task Checks
        # ---------------------------------------------------------
        foreach ($Task in $Baseline.ScheduledTasks.Expected) {
            $Exists = Get-ScheduledTask -TaskPath (Split-Path $Task -Parent) `
                                        -TaskName (Split-Path $Task -Leaf) `
                                        -ErrorAction SilentlyContinue

            if (-not $Exists) {
                Write-Log -Message "Scheduled task missing: $Task" -Level "WARN"
                $Global:DriftDetectedCount++
            }
        }

        Write-Host "Baseline check completed." -ForegroundColor Green
        Write-Log -Message "Baseline check completed. Drift count: $Global:DriftDetectedCount"
    }
    catch {
        Write-Host "Baseline check failed: $_" -ForegroundColor Red
        Write-Log -Message "Baseline check error: $_"
    }
}
