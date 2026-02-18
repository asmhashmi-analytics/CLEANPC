# SystemIntegrity.ps1
# SFC integrity checks (verify-only + repair) with cadence/profile awareness

function Invoke-SFCVerifyOnly {

    Write-Host "Running SFC /verifyonly (integrity scan, no repair)..." -ForegroundColor Cyan
    Write-Log -Message "SFC /verifyonly started."

    try {
        & sfc /verifyonly
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Host "SFC /verifyonly completed. No integrity violations detected." -ForegroundColor Green
            Write-Log -Message "SFC /verifyonly completed. No integrity violations detected."
            return "Healthy"
        }
        elseif ($exitCode -eq 1) {
            Write-Host "SFC /verifyonly detected integrity violations (no repair performed)." -ForegroundColor Yellow
            Write-Log -Message "SFC /verifyonly detected integrity violations (no repair performed)."
            return "Issues"
        }
        else {
            Write-Host "SFC /verifyonly encountered an error. Exit code: $exitCode" -ForegroundColor Yellow
            Write-Log -Message "SFC /verifyonly error. Exit code: $exitCode"
            return "Error"
        }
    }
    catch {
        Write-Host "SFC /verifyonly failed: $_" -ForegroundColor Red
        Write-Log -Message "SFC /verifyonly exception: $_"
        return "Error"
    }
}

function Invoke-SFCScanNow {

    Write-Host "Running SFC /scannow (full repair)..." -ForegroundColor Cyan
    Write-Log -Message "SFC /scannow started."

    try {
        & sfc /scannow
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Host "SFC /scannow completed. No integrity violations detected." -ForegroundColor Green
            Write-Log -Message "SFC /scannow completed. No integrity violations detected."
            return "Healthy"
        }
        elseif ($exitCode -eq 1) {
            Write-Host "SFC /scannow completed. Integrity violations were found and repaired where possible." -ForegroundColor Yellow
            Write-Log -Message "SFC /scannow completed. Integrity violations were found and repaired where possible."
            return "Repaired"
        }
        else {
            Write-Host "SFC /scannow encountered an error. Exit code: $exitCode" -ForegroundColor Yellow
            Write-Log -Message "SFC /scannow error. Exit code: $exitCode"
            return "Error"
        }
    }
    catch {
        Write-Host "SFC /scannow failed: $_" -ForegroundColor Red
        Write-Log -Message "SFC /scannow exception: $_"
        return "Error"
    }
}

function Invoke-SystemIntegrityCheck {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Mode,              # Weekly, Monthly, Quarterly, AsNeeded
        [Parameter(Mandatory=$true)]
        $ProfileSettings            # Contains .Level = Safe/Power/Hardcore
    )

    Write-Host "Checking system file integrity (SFC)..." -ForegroundColor Cyan
    Write-Log -Message "System integrity check started. Mode=$Mode Profile=$($ProfileSettings.Level)"

    # Decide behaviour based on cadence + profile
    $runVerifyOnly = $false
    $runScanNow    = $false

    switch ($Mode) {
        "Weekly" {
            # No SFC in weekly by design
            Write-Host "SFC skipped for Weekly maintenance." -ForegroundColor Yellow
            Write-Log -Message "SFC skipped (Weekly mode)."
            return "Skipped"
        }
        "Monthly" {
            $runVerifyOnly = $true
        }
        "AsNeeded" {
            $runVerifyOnly = $true
        }
        "Quarterly" {
            $runScanNow = $true
        }
    }

    # HARDCORE always gets full repair (except Weekly)
    if ($ProfileSettings.Level -eq "Hardcore" -and $Mode -ne "Weekly") {
        $runVerifyOnly = $false
        $runScanNow    = $true
    }

    if ($runVerifyOnly) {
        $result = Invoke-SFCVerifyOnly

        if ($result -eq "Healthy") {
            Write-Host "System files are healthy. Skipping SFC /scannow (repair not required)." -ForegroundColor Green
            Write-Log -Message "SFC /scannow skipped (verifyonly healthy)."
        }
        elseif ($result -eq "Issues") {
            Write-Host "Integrity issues detected by SFC /verifyonly. Consider running SFC /scannow or Quarterly/HARDCORE maintenance." -ForegroundColor Yellow
            Write-Log -Message "SFC /verifyonly detected issues. Advisory: run SFC /scannow."
        }

        return $result
    }

    if ($runScanNow) {
        $result = Invoke-SFCScanNow

        if ($result -eq "Repaired") {
            Write-Host "System file integrity issues were repaired. A reboot may be recommended." -ForegroundColor Yellow
            Write-Log -Message "System file repairs applied. Reboot may be recommended."
        }

        return $result
    }

    Write-Host "No SFC action selected for this mode/profile." -ForegroundColor Yellow
    Write-Log -Message "System integrity check ended with no action."
    return "Skipped"
}
