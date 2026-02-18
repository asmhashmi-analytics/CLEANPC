# ComponentStore.ps1
# DISM health checks + conditional repair logic (with visible status)

function Invoke-ComponentStoreCheckHealth {

    Write-Host "Checking Component Store health (DISM /checkhealth)..." -ForegroundColor Cyan
    Write-Log -Message "Component Store health check started."

    try {
        $result = dism /online /cleanup-image /checkhealth

        if ($result -match "No component store corruption detected") {
            $Global:LastComponentStoreState = "Healthy"
            Write-Host "Component Store is healthy. No corruption detected." -ForegroundColor Green
            Write-Log -Message "Component Store healthy (no corruption detected)."
            return "Healthy"
        }
        elseif ($result -match "The component store is repairable") {
            $Global:LastComponentStoreState = "Corrupt"
            Write-Host "Component Store corruption detected. Repair is possible." -ForegroundColor Yellow
            Write-Log -Message "Component Store corruption detected (repairable)."
            return "Corrupt"
        }
        else {
            $Global:LastComponentStoreState = "Unknown"
            Write-Host "Component Store state could not be clearly determined from DISM output." -ForegroundColor Yellow
            Write-Log -Message "Component Store state ambiguous. Raw DISM output captured."
            return "Unknown"
        }
    }
    catch {
        $Global:LastComponentStoreState = "Error"
        Write-Host "Component Store check failed: $_" -ForegroundColor Red
        Write-Log -Message "Component Store check error: $_"
        return "Error"
    }
}

function Invoke-ComponentStoreCheck {
    $state = Invoke-ComponentStoreCheckHealth

    if ($state -eq "Corrupt") {
        Write-Host "Component Store is repairable. Proceeding with DISM /restorehealth..." -ForegroundColor Yellow
        Invoke-ComponentStoreRepair
        return "Repaired"
    }

    if ($state -eq "Healthy") {
        Write-Host "Component Store is healthy. Skipping DISM /restorehealth (no repair needed)." -ForegroundColor Green
        Write-Log -Message "Component Store repair skipped (healthy)."
    }
    elseif ($state -eq "Unknown") {
        Write-Host "Component Store state is ambiguous. Skipping automatic repair." -ForegroundColor DarkYellow
        Write-Log -Message "Component Store repair skipped (ambiguous state)."
    }

    return $state
}

function Invoke-ComponentStoreRepair {

    Write-Host "Repairing Component Store corruption (DISM /restorehealth)..." -ForegroundColor Cyan
    Write-Log -Message "Component Store repair started."

    try {
        dism /online /cleanup-image /restorehealth | Out-Null

        Write-Host "Component Store repair completed successfully." -ForegroundColor Green
        Write-Log -Message "Component Store repair completed successfully."
    }
    catch {
        Write-Host "Component Store repair failed: $_" -ForegroundColor Red
        Write-Log -Message "Component Store repair error: $_"
    }
}
