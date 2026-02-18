# HealthReport.ps1
# Formats the results of the last CLEANPC run into a readable report

function Invoke-HealthReport {

    if (-not $Global:LastRunResults) {
        return "No run data available. Please run CLEANPC first."
    }

    $R = $Global:LastRunResults

    $Report = @()
    $Report += "==============================="
    $Report += " CLEANPC HEALTH REPORT"
    $Report += " Generated: $(Get-Date)"
    $Report += "==============================="
    $Report += ""
    $Report += "Overall Health Score: $($R.Score)"
    $Report += ""
    $Report += "---- Core Governance ----"
    $Report += "Baseline:        $($R.Baseline)"
    $Report += "Drift:           $($R.Drift)"
    $Report += "Self-Healing:    $($R.SelfHealing)"
    $Report += "Component Store: $($R.ComponentStore)"
    $Report += ""
    $Report += "---- System Governance ----"
    $Report += "Registry:        $($R.Registry)"
    $Report += "Services:        $($R.Services)"
    $Report += "Tasks:           $($R.Tasks)"
    $Report += "Certificates:    $($R.Certificates)"
    $Report += ""
    $Report += "---- Hardening ----"
    $Report += "AppX:            $($R.AppX)"
    $Report += "ASR:             $($R.ASR)"
    $Report += "Telemetry:       $($R.Telemetry)"
    $Report += ""
    $Report += "---- Storage ----"
    $Report += "SSD Health:      $($R.SSDHealth)"
    $Report += "TRIM:            $($R.TRIM)"
    $Report += "SMART:           $($R.SMART)"
    $Report += ""
    $Report += "==============================="
    $Report += " End of Report"
    $Report += "==============================="

    return $Report -join "`n"
}
