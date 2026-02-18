# RegistryGovernance.ps1
# Ensures key registry paths exist and are healthy

function Invoke-RegistryGovernance {
    param(
        [Parameter(Mandatory=$true)]
        $ProfileSettings
    )

    Write-Host "Checking registry health..." -ForegroundColor Cyan
    Write-Log -Message "Registry governance started."

    $Created = 0
    $Missing = 0

    try {
        $RegistryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion",
            "HKLM:\SYSTEM\CurrentControlSet\Services",
            "HKLM:\SOFTWARE\Policies\Microsoft"
        )

        foreach ($Path in $RegistryPaths) {

            if (Test-Path $Path) {
                Write-Log -Message "Registry OK: $Path"
            }
            else {
                Write-Host "Missing registry path: $Path" -ForegroundColor Yellow
                Write-Log -Message "Registry missing: $Path"

                try {
                    New-Item -Path $Path -Force | Out-Null
                    Write-Log -Message "Created missing registry path: $Path"
                    $Created++
                }
                catch {
                    Write-Log -Message "Failed to create registry path: $Path"
                    $Missing++
                }
            }
        }

        Write-Log -Message "Registry governance completed. Created=$Created Missing=$Missing"

        if ($Missing -gt 0) { return "Partial" }
        if ($Created -gt 0) { return "Created" }
        return "Healthy"
    }
    catch {
        Write-Host "Registry governance failed: $_" -ForegroundColor Red
        Write-Log -Message "Registry governance error: $_"
        return "Error"
    }
}
