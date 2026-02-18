# TRIM.ps1
# Checks whether TRIM is enabled and sets global state

function Invoke-TRIMCheck {

    Write-Host "Checking TRIM status..." -ForegroundColor Cyan
    Write-Log -Message "TRIM check started."

    # Reset state
    $Global:TRIMEnabled = $false

    try {
        $Result = fsutil behavior query DisableDeleteNotify 2>$null

        if (-not $Result) {
            Write-Host "Unable to query TRIM status." -ForegroundColor Yellow
            Write-Log -Message "TRIM query failed."
            return "Unknown"
        }

        if ($Result -match "DisableDeleteNotify\s*=\s*0") {
            $Global:TRIMEnabled = $true
            Write-Host "TRIM is enabled." -ForegroundColor Green
            Write-Log -Message "TRIM enabled."
            return "Enabled"
        }
        elseif ($Result -match "DisableDeleteNotify\s*=\s*1") {
            $Global:TRIMEnabled = $false
            Write-Host "TRIM is DISABLED." -ForegroundColor Yellow
            Write-Log -Message "TRIM disabled."
            return "Disabled"
        }
        else {
            Write-Host "Unknown TRIM status." -ForegroundColor Yellow
            Write-Log -Message "Unknown TRIM status: $Result"
            return "Unknown"
        }
    }
    catch {
        Write-Host "TRIM check failed: $_" -ForegroundColor Red
        Write-Log -Message "TRIM check error: $_"
        return "Error"
    }
}
