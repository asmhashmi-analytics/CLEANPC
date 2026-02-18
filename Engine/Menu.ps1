# Menu.ps1
# CLEANPC Interactive Menu System

function Show-MaintenanceMenu {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "        CLEANPC Maintenance Menu" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host " Profile: $Profile" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " 1. Weekly Maintenance"
    Write-Host " 2. Monthly Maintenance"
    Write-Host " 3. Quarterly Maintenance"
    Write-Host " 4. As-Needed Maintenance"
    Write-Host " 5. Full Health Report"
    Write-Host " 6. Exit"
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
}

function Show-CleanPCMenu {

    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("SAFE","POWER","HARDCORE")]
        [string]$Profile
    )

    # Load profile settings
    $ProfileSettings = Get-CleanPCProfile -Profile $Profile

    if (-not $ProfileSettings) {
        Write-Host "Invalid profile. Aborting." -ForegroundColor Red
        return
    }

    # Show menu ONCE before entering the loop
    Show-MaintenanceMenu

    while ($true) {

        $Choice = Read-Host "Select an option (1-6)"

        switch ($Choice) {

            "1" {
                Write-Host "Running Weekly Maintenance..." -ForegroundColor Green
                & "$PSScriptRoot\..\Schedules\Weekly.ps1" -ProfileSettings $ProfileSettings
            }

            "2" {
                Write-Host "Running Monthly Maintenance..." -ForegroundColor Green
                & "$PSScriptRoot\..\Schedules\Monthly.ps1" -ProfileSettings $ProfileSettings
            }

            "3" {
                Write-Host "Running Quarterly Maintenance..." -ForegroundColor Green
                & "$PSScriptRoot\..\Schedules\Quarterly.ps1" -ProfileSettings $ProfileSettings
            }

            "4" {
                Write-Host "Running As-Needed Maintenance..." -ForegroundColor Green
                & "$PSScriptRoot\..\Schedules\AsNeeded.ps1" -ProfileSettings $ProfileSettings
            }

            "5" {
                Write-Host "Generating Health Report..." -ForegroundColor Green
                & "$PSScriptRoot\HealthReport.ps1" -ProfileSettings $ProfileSettings
            }

            "6" {
                Write-Host "Exiting CLEANPC. Goodbye!" -ForegroundColor Cyan
                return
            }

            default {
                Write-Host "Invalid selection. Please choose 1-6." -ForegroundColor Red
            }
        }

        Write-Host ""
        Write-Host "------------------------------------------"
        Write-Host " Action completed. Returning to menu..."
        Write-Host "------------------------------------------"
        Write-Host ""

        # Show menu AGAIN after each action
        Show-MaintenanceMenu
    }
}
# Menu.ps1
# CLEANPC Interactive Menu System

function Show-MaintenanceMenu {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "        CLEANPC Maintenance Menu" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host " Profile: $Profile" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " 1. Weekly Maintenance"
    Write-Host " 2. Monthly Maintenance"
    Write-Host " 3. Quarterly Maintenance"
    Write-Host " 4. As-Needed Maintenance"
    Write-Host " 5. Full Health Report"
    Write-Host " 6. Exit"
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
}

function Show-CleanPCMenu {

    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("SAFE","POWER","HARDCORE")]
        [string]$Profile
    )

    # Load profile settings
    $ProfileSettings = Get-CleanPCProfile -Profile $Profile

    if (-not $ProfileSettings) {
        Write-Host "Invalid profile. Aborting." -ForegroundColor Red
        return
    }

    # Show menu ONCE before entering the loop
    Show-MaintenanceMenu

    while ($true) {

        $Choice = Read-Host "Select an option (1-6)"

        switch ($Choice) {

            "1" {
                Write-Host "Running Weekly Maintenance..." -ForegroundColor Green
                & "$PSScriptRoot\..\Schedules\Weekly.ps1" -ProfileSettings $ProfileSettings
            }

            "2" {
                Write-Host "Running Monthly Maintenance..." -ForegroundColor Green
                & "$PSScriptRoot\..\Schedules\Monthly.ps1" -ProfileSettings $ProfileSettings
            }

            "3" {
                Write-Host "Running Quarterly Maintenance..." -ForegroundColor Green
                & "$PSScriptRoot\..\Schedules\Quarterly.ps1" -ProfileSettings $ProfileSettings
            }

            "4" {
                Write-Host "Running As-Needed Maintenance..." -ForegroundColor Green
                & "$PSScriptRoot\..\Schedules\AsNeeded.ps1" -ProfileSettings $ProfileSettings
            }

            "5" {
                Write-Host "Generating Health Report..." -ForegroundColor Green
                & "$PSScriptRoot\HealthReport.ps1" -ProfileSettings $ProfileSettings
            }

            "6" {
                Write-Host "Exiting CLEANPC. Goodbye!" -ForegroundColor Cyan
                return
            }

            default {
                Write-Host "Invalid selection. Please choose 1-6." -ForegroundColor Red
            }
        }

        Write-Host ""
        Write-Host "------------------------------------------"
        Write-Host " Action completed. Returning to menu..."
        Write-Host "------------------------------------------"
        Write-Host ""

        # Show menu AGAIN after each action
        Show-MaintenanceMenu
    }
}
