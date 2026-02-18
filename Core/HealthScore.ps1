# HealthScore.ps1
# CLEANPC System Health Scoring Engine (Lightweight Version)

function Get-HealthScore {

    $Score = 100

    # ---------------------------------------------------------
    # 1. Drift Penalty
    # ---------------------------------------------------------
    if ($Global:DriftDetectedCount -gt 0) {
        $Score -= [Math]::Min($Global:DriftDetectedCount * 2, 20)
    }

    # ---------------------------------------------------------
    # 2. Component Store Penalty
    # ---------------------------------------------------------
    if ($Global:LastComponentStoreState -eq "Corrupt") {
        $Score -= 20
    }
    elseif ($Global:LastComponentStoreState -eq "Repaired") {
        $Score -= 10
    }

    # ---------------------------------------------------------
    # 3. Storage Penalty
    # ---------------------------------------------------------
    if ($Global:SSDHealthWarning) {
        $Score -= 10
    }

    if (-not $Global:TRIMEnabled) {
        $Score -= 5
    }

    # ---------------------------------------------------------
    # Normalize Score
    # ---------------------------------------------------------
    if ($Score -lt 0) { $Score = 0 }
    if ($Score -gt 100) { $Score = 100 }

    return $Score
}
