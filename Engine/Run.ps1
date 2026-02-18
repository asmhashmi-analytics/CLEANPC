# Run.ps1 — CLEANPC main orchestrator (corrected for your folder structure)

# Engine-level modules
. "$PSScriptRoot\Logging.ps1"
. "$PSScriptRoot\Profiles.ps1"

# Core modules
. "$PSScriptRoot\..\Core\Baseline.ps1"
. "$PSScriptRoot\..\Core\DriftDetection.ps1"
. "$PSScriptRoot\..\Core\SelfHealing.ps1"
. "$PSScriptRoot\..\Core\ComponentStore.ps1"
. "$PSScriptRoot\..\Core\RegistryGovernance.ps1"
. "$PSScriptRoot\..\Core\ServicesGovernance.ps1"
. "$PSScriptRoot\..\Core\TasksGovernance.ps1"
. "$PSScriptRoot\..\Core\Certificates.ps1"
. "$PSScriptRoot\..\Core\SystemIntegrity.ps1"

# Hardening modules
. "$PSScriptRoot\..\Hardening\AppX.ps1"
. "$PSScriptRoot\..\Hardening\AttackSurface.ps1"
. "$PSScriptRoot\..\Hardening\Telemetry.ps1"

# Storage modules
. "$PSScriptRoot\..\Storage\SSDHealth.ps1"
. "$PSScriptRoot\..\Storage\TRIM.ps1"
. "$PSScriptRoot\..\Storage\SMART.ps1"


function Invoke-CleanPC {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Mode,              # Weekly, Monthly, Quarterly, AsNeeded, FullReport
        [Parameter(Mandatory=$true)]
        $ProfileSettings            # Contains .Level = Safe/Power/Hardcore
    )

    Write-Host "Running CLEANPC..." -ForegroundColor Cyan
    Write-Log -Message "CLEANPC run started. Mode=$Mode Profile=$($ProfileSettings.Level)"

    # 1. Baseline + Drift
    Invoke-BaselineCheck
    Invoke-DriftDetection
    Invoke-SelfHealing

    # 2. Component Store (DISM)
    $componentResult = Invoke-ComponentStoreCheck

    # 3. System Integrity (SFC)
    $integrityResult = Invoke-SystemIntegrityCheck -Mode $Mode -ProfileSettings $ProfileSettings

    # 4. Governance modules
    $regResult   = Invoke-RegistryGovernance -ProfileSettings $ProfileSettings
    $svcResult   = Invoke-ServicesGovernance -ProfileSettings $ProfileSettings
    $taskResult  = Invoke-TasksGovernance -ProfileSettings $ProfileSettings
    $certResult  = Invoke-CertificateCheck -ProfileSettings $ProfileSettings
    $appxResult  = Invoke-AppXGovernance -ProfileSettings $ProfileSettings
    $asrResult   = Invoke-AttackSurfaceReduction -ProfileSettings $ProfileSettings
    $teleResult  = Invoke-TelemetryGovernance -ProfileSettings $ProfileSettings

    # 5. Storage health
    $ssdResult   = Invoke-SSDHealthCheck
    $trimResult  = Invoke-TRIMCheck
    $smartResult = Invoke-SMARTDeepScan

    # 6. Health score
    $Score = 100

    $penalize = {
        param([string]$result, [int]$amount)
        if ($result -in @("Issues","Warning","Partial","Error","Repaired")) {
            return $amount
        }
        return 0
    }

    $Score -= & $penalize $componentResult 5
    $Score -= & $penalize $integrityResult 5
    $Score -= & $penalize $regResult 3
    $Score -= & $penalize $svcResult 3
    $Score -= & $penalize $taskResult 3
    $Score -= & $penalize $certResult 3
    $Score -= & $penalize $ssdResult 3
    $Score -= & $penalize $trimResult 2
    $Score -= & $penalize $smartResult 4

    if ($Score -lt 0) { $Score = 0 }

    Write-Host "CLEANPC run completed. Health Score: $Score/100" -ForegroundColor Green
    Write-Log -Message "CLEANPC run completed. Health Score: $Score/100"

    return $Score
}
