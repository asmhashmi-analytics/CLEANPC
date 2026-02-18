# SelfHealing.ps1
# CLEANPC Self-Healing Engine (Final)

function Invoke-SelfHealing {

    Write-Host "Applying self-healing..." -ForegroundColor Cyan
    Write-Log -Message "Self-healing started."

    if (-not $Global:DetectedDrift -or $Global:DetectedDrift.Count -eq 0) {
        Write-Host "No drift to heal." -ForegroundColor Green
        Write-Log -Message "No drift to heal."
        return
    }

    try {
        foreach ($Item in $Global:DetectedDrift) {

            $Type     = $Item.Type
            $Name     = $Item.Item
            $Expected = $Item.Expected
            $Actual   = $Item.Actual

            Write-Host "Healing [$Type] $Name (Expected: $Expected, Actual: $Actual)" -ForegroundColor Yellow
            Write-Log  -Message "Healing [$Type] $Name Expected=$Expected Actual=$Actual"

            switch ($Type) {

                # ---------------------------------------------------------
                # Registry Healing
                # ---------------------------------------------------------
                "Registry" {
                    if ($Expected -eq "Exists" -and $Actual -eq "Missing") {
                        try {
                            New-Item -Path $Name -Force | Out-Null
                            Write-Log -Message "Recreated registry key: $Name"
                        }
                        catch {
                            Write-Log -Message "Failed to recreate registry key: $Name" -Level "ERROR"
                        }
                    }
                }

                # ---------------------------------------------------------
                # Service Healing
                # ---------------------------------------------------------
                "Service" {
                    if ($Expected -eq "Running" -and $Actual -ne "Running") {
                        try {
                            Start-Service -Name $Name -ErrorAction SilentlyContinue
                            Write-Log -Message "Started service: $Name"
                        }
                        catch {
                            Write-Log -Message "Failed to start service: $Name" -Level "ERROR"
                        }
                    }

                    if ($Expected -eq "Stopped" -and $Actual -ne "Stopped") {
                        try {
                            Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
                            Write-Log -Message "Stopped service: $Name"
                        }
                        catch {
                            Write-Log -Message "Failed to stop service: $Name" -Level "ERROR"
                        }
                    }
                }

                # ---------------------------------------------------------
                # Scheduled Task Healing
                # ---------------------------------------------------------
                "ScheduledTask" {
                    Write-Log -Message "Scheduled task missing: $Name (no auto-repair definition yet)"
                }

                # ---------------------------------------------------------
                # Component Store Healing (Flag Only)
                # ---------------------------------------------------------
                "ComponentStore" {
                    # Do NOT run DISM here — AsNeeded/Quarterly handle it
                    Write-Log -Message "Component store corruption flagged. DISM repair deferred to cadence."
                }
            }
        }

        Write-Host "Self-healing completed." -ForegroundColor Green
        Write-Log -Message "Self-healing completed successfully."
    }
    catch {
        Write-Host "Self-healing failed: $_" -ForegroundColor Red
        Write-Log -Message "Self-healing error: $_"
    }
}
