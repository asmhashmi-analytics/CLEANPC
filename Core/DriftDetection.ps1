# DriftDetection.ps1
# CLEANPC Drift Detection Engine (Final)

$Global:BaselinePath = "C:\cleanpc\baseline.json"

function Invoke-DriftDetection {

    Write-Host "Checking for system drift..." -ForegroundColor Cyan
    Write-Log -Message "Drift detection started."

    $Global:DetectedDrift = @()
    $Global:DriftDetectedCount = 0
    $Global:DetectedCorruption = $false

    if (-not (Test-Path $Global:BaselinePath)) {
        Write-Host "Baseline not found. Run baseline build first." -ForegroundColor Red
        Write-Log -Message "Baseline missing. Drift detection aborted."
        return
    }

    try {
        $Baseline = Get-Content -Path $Global:BaselinePath | ConvertFrom-Json

        # ---------------------------------------------------------
        # Registry Drift
        # ---------------------------------------------------------
        foreach ($Key in $Baseline.Registry.Keys) {
            if (-not (Test-Path $Key)) {
                $Global:DetectedDrift += @{
                    Type     = "Registry"
                    Item     = $Key
                    Expected = "Exists"
                    Actual   = "Missing"
                }
                $Global:DriftDetectedCount++
            }
        }

        # ---------------------------------------------------------
        # Service Drift
        # ---------------------------------------------------------
        foreach ($Svc in $Baseline.Services.ExpectedRunning) {
            $State = (Get-Service -Name $Svc -ErrorAction SilentlyContinue).Status
            if ($State -ne "Running") {
                $Global:DetectedDrift += @{
                    Type     = "Service"
                    Item     = $Svc
                    Expected = "Running"
                    Actual   = $State
                }
                $Global:DriftDetectedCount++
            }
        }

        foreach ($Svc in $Baseline.Services.ExpectedStopped) {
            $State = (Get-Service -Name $Svc -ErrorAction SilentlyContinue).Status
            if ($State -ne "Stopped") {
                $Global:DetectedDrift += @{
                    Type     = "Service"
                    Item     = $Svc
                    Expected = "Stopped"
                    Actual   = $State
                }
                $Global:DriftDetectedCount++
            }
        }

        # ---------------------------------------------------------
        # Scheduled Task Drift
        # ---------------------------------------------------------
        foreach ($Task in $Baseline.ScheduledTasks.Expected) {
            $Exists = Get-ScheduledTask -TaskPath (Split-Path $Task -Parent) `
                                        -TaskName (Split-Path $Task -Leaf) `
                                        -ErrorAction SilentlyContinue

            if (-not $Exists) {
                $Global:DetectedDrift += @{
                    Type     = "ScheduledTask"
                    Item     = $Task
                    Expected = "Exists"
                    Actual   = "Missing"
                }
                $Global:DriftDetectedCount++
            }
        }

        # ---------------------------------------------------------
        # Component Store Drift (Corruption Flag)
        # ---------------------------------------------------------
        if ($Baseline.ComponentStore.CheckHealth) {
            $Health = Invoke-ComponentStoreCheckHealth
            if ($Health -eq "Corrupt") {
                $Global:DetectedCorruption = $true
                $Global:DetectedDrift += @{
                    Type     = "ComponentStore"
                    Item     = "WinSxS"
                    Expected = "Healthy"
                    Actual   = "Corrupt"
                }
                $Global:DriftDetectedCount++
            }
        }

        # ---------------------------------------------------------
        # Output Results
        # ---------------------------------------------------------
        if ($Global:DriftDetectedCount -eq 0) {
            Write-Host "No drift detected." -ForegroundColor Green
            Write-Log -Message "No drift detected."
        }
        else {
            Write-Host "Drift detected:" -ForegroundColor Yellow
            foreach ($Item in $Global:DetectedDrift) {
                Write-Host " - [$($Item.Type)] $($Item.Item): Expected $($Item.Expected), Actual $($Item.Actual)" -ForegroundColor Yellow
                Write-Log -Message "Drift: [$($Item.Type)] $($Item.Item) Expected=$($Item.Expected) Actual=$($Item.Actual)"
            }
        }
    }
    catch {
        Write-Host "Drift detection failed: $_" -ForegroundColor Red
        Write-Log -Message "Drift detection error: $_"
    }
}
