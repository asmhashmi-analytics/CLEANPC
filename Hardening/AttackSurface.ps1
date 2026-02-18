# AttackSurface.ps1
# Applies Microsoft Defender Attack Surface Reduction (ASR) rules

function Invoke-AttackSurfaceReduction {
    param(
        [Parameter(Mandatory=$true)]
        $ProfileSettings
    )

    Write-Host "Applying Attack Surface Reduction (ASR) rules..." -ForegroundColor Cyan
    Write-Log -Message "ASR hardening started."

    try {
        # ---------------------------------------------------------
        # Define ASR rules by profile
        # ---------------------------------------------------------

        $PowerRules = @{
            "D4F940AB-401B-4EFC-AADC-AD5F3C50688A" = 1  # Block Office child processes
            "3B576869-A4EC-4529-8536-B80A7769E899" = 1  # Block Office from creating executables
            "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84" = 1  # Block credential stealing
        }

        $HardcoreRules = @{
            "D3E037E1-3EB8-44C8-A917-57927947596D" = 1  # Block untrusted USB
            "26190899-1602-49E8-8B27-EB1D0A1CE869" = 1  # Block executable content from email/webmail
            "5BEB7EFE-FD9A-4556-801D-275E5FFC04CC" = 1  # Block persistence through WMI
        }

        # ---------------------------------------------------------
        # Select rules based on profile
        # ---------------------------------------------------------

        switch ($ProfileSettings.Level) {
            "Safe" {
                Write-Log -Message "ASR skipped (SAFE profile)"
                Write-Host "ASR skipped for SAFE profile." -ForegroundColor Yellow
                return "NoneApplied"
            }

            "Power" {
                $RulesToApply = $PowerRules
            }

            "Hardcore" {
                $RulesToApply = $PowerRules + $HardcoreRules
            }
        }

        # ---------------------------------------------------------
        # Apply ASR rules
        # ---------------------------------------------------------

        foreach ($Rule in $RulesToApply.GetEnumerator()) {

            $RuleId = $Rule.Key
            $Mode   = $Rule.Value

            Write-Log -Message "Applying ASR rule: $RuleId (Mode: $Mode)"

            Add-MpPreference -AttackSurfaceReductionRules_Ids $RuleId `
                             -AttackSurfaceReductionRules_Actions $Mode `
                             -ErrorAction SilentlyContinue
        }

        Write-Host "ASR rules applied." -ForegroundColor Green
        Write-Log -Message "ASR hardening completed successfully."

        if ($ProfileSettings.Level -eq "Power") { return "PartialApplied" }
        if ($ProfileSettings.Level -eq "Hardcore") { return "FullApplied" }
    }
    catch {
        Write-Host "ASR hardening failed: $_" -ForegroundColor Red
        Write-Log -Message "ASR hardening error: $_"
        return "Error"
    }
}
