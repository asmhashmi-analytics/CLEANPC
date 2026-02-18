# Telemetry.ps1
# Reduces Windows telemetry and unnecessary data collection

function Invoke-TelemetryGovernance {
    param(
        [Parameter(Mandatory=$true)]
        $ProfileSettings
    )

    Write-Host "Applying telemetry governance..." -ForegroundColor Cyan
    Write-Log -Message "Telemetry hardening started."

    try {
        # --- Basic telemetry reduction (Safe for all profiles) ---
        Write-Log -Message "Setting AllowTelemetry = 1 (Basic)"
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
                         -Name "AllowTelemetry" -Value 1 -Type DWord -Force

        # --- Disable Compatibility Telemetry (DiagTrack) ---
        Write-Log -Message "Disabling DiagTrack service"
        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue

        # --- Disable Customer Experience Improvement Program ---
        Write-Log -Message "Disabling CEIP tasks"
        $CEIPTasks = @(
            "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
            "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
            "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
        )

        foreach ($Task in $CEIPTasks) {
            try {
                $Folder = Split-Path $Task -Parent
                $Name   = Split-Path $Task -Leaf
                Disable-ScheduledTask -TaskPath $Folder -TaskName $Name -ErrorAction SilentlyContinue
                Write-Log -Message "Disabled CEIP task: $Task"
            }
            catch {
                Write-Log -Message "Failed to disable CEIP task: $Task"
            }
        }

        # --- Disable Feedback Hub notifications (current user only) ---
        Write-Log -Message "Disabling Feedback Hub notifications"
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" `
                         -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord -Force

        # --- Optional deeper telemetry reduction for HARDCORE profile ---
        if ($ProfileSettings.Level -eq "Hardcore") {

            Write-Host "Applying HARDCORE telemetry reductions..." -ForegroundColor Yellow
            Write-Log -Message "Applying HARDCORE telemetry reductions"

            # Disable Windows Error Reporting
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Force | Out-Null
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" `
                             -Name "Disabled" -Value 1 -Type DWord -Force

            # Disable handwriting/ink telemetry
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Input\TIPC" -Force | Out-Null
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Input\TIPC" `
                             -Name "Enabled" -Value 0 -Type DWord -Force
        }

        Write-Host "Telemetry governance applied." -ForegroundColor Green
        Write-Log -Message "Telemetry hardening completed successfully."
        return "Success"
    }
    catch {
        Write-Host "Telemetry hardening failed: $_" -ForegroundColor Red
        Write-Log -Message "Telemetry hardening error: $_"
        return "Error"
    }
}
