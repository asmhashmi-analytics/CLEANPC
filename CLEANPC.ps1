# CLEANPC.ps1
# Root launcher for the CLEANPC Governance Engine

param(
    [switch]$Weekly,
    [switch]$Monthly,
    [switch]$Quarterly,
    [switch]$AsNeeded,
    [switch]$Health
)

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "          CLEANPC — Windows Engine" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Choose a profile to continue:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. SAFE      (Minimal changes, low risk)"
Write-Host "   2. POWER     (Balanced, recommended)"
Write-Host "   3. HARDCORE  (Strict governance, aggressive cleanup)"
Write-Host ""
Write-Host "   M. Read User Manual"
Write-Host "   X. Exit"
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan

$Profile = $null

while (-not $Profile) {

    $Selection = Read-Host "Enter your choice"

    switch ($Selection.ToUpper()) {

        "1" { $Profile = "SAFE" }
        "2" { $Profile = "POWER" }
        "3" { $Profile = "HARDCORE" }

        "M" {
            Clear-Host
            Write-Host "============================================" -ForegroundColor Cyan
            Write-Host "            CLEANPC — User Manual" -ForegroundColor Cyan
            Write-Host "============================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "CLEANPC is a modular Windows governance and self-healing engine." -ForegroundColor Yellow
            Write-Host "This summary covers:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host " - Profiles (SAFE, POWER, HARDCORE)"
            Write-Host " - Cadences (Weekly, Monthly, Quarterly, As-Needed)"
            Write-Host " - Governance modules (Registry, Services, Tasks, Certificates)"
            Write-Host " - Hardening modules (AppX, ASR, Telemetry)"
            Write-Host " - Storage modules (SSD, TRIM, SMART)"
            Write-Host ""
            Write-Host "Full documentation will now open in Notepad." -ForegroundColor Green
            Write-Host ""
            Write-Host "Note: CLEANPC is provided as-is. Use at your own risk." -ForegroundColor DarkYellow
            Write-Host ""

            Start-Sleep -Seconds 2

# Resolve documentation.md path (in CLEANPC\Docs)
$DocPath = Join-Path $PSScriptRoot "Docs\Documentation.md"
$DocPath = (Resolve-Path $DocPath).Path

if (Test-Path $DocPath) {
    Start-Process notepad.exe $DocPath
} else {
    Write-Host "Documentation.md not found at: $DocPath" -ForegroundColor Red
}

            Write-Host ""
            Write-Host "Press any key to return to the profile menu..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

            # Reprint the engine menu
            Clear-Host
            Write-Host "============================================" -ForegroundColor Cyan
            Write-Host "          CLEANPC — Windows Engine" -ForegroundColor Cyan
            Write-Host "============================================" -ForegroundColor Cyan
            Write-Host " Choose a profile to continue:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "   1. SAFE      (Minimal changes, low risk)"
            Write-Host "   2. POWER     (Balanced, recommended)"
            Write-Host "   3. HARDCORE  (Strict governance, aggressive cleanup)"
            Write-Host ""
            Write-Host "   M. Read User Manual"
            Write-Host "   X. Exit"
            Write-Host ""
            Write-Host "============================================" -ForegroundColor Cyan
        }

        "X" {
            Write-Host "Exiting CLEANPC. Goodbye!" -ForegroundColor Cyan
            exit
        }

        default {
            Write-Host "Invalid selection. Please choose 1, 2, 3, M, or X." -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Launching CLEANPC with profile: $Profile" -ForegroundColor Cyan

# ---------------------------------------------------------
# Load Engine Modules
# ---------------------------------------------------------

$EnginePath = Join-Path $PSScriptRoot "Engine"

. "$EnginePath\Logging.ps1"
. "$EnginePath\Profiles.ps1"
. "$EnginePath\Run.ps1"
. "$EnginePath\Menu.ps1"

# Load profile settings
$ProfileSettings = Get-CleanPCProfile -Profile $Profile

# ---------------------------------------------------------
# CLI Flag Mode (Direct Execution)
# ---------------------------------------------------------

if ($Weekly)    { Invoke-Weekly    -ProfileSettings $ProfileSettings; exit }
if ($Monthly)   { Invoke-Monthly   -ProfileSettings $ProfileSettings; exit }
if ($Quarterly) { Invoke-Quarterly -ProfileSettings $ProfileSettings; exit }
if ($AsNeeded)  { Invoke-AsNeeded  -ProfileSettings $ProfileSettings; exit }
if ($Health)    { Show-HealthReport; exit }

# ---------------------------------------------------------
# Interactive Menu Mode (Default)
# ---------------------------------------------------------

Show-CleanPCMenu -Profile $Profile
