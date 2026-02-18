# AppX.ps1
# Governs AppX packages: removes bloat, protects core apps, blocks reinstalls

function Invoke-AppXGovernance {
    param(
        [Parameter(Mandatory=$true)]
        $ProfileSettings
    )

    Write-Host "Applying AppX governance..." -ForegroundColor Cyan
    Write-Log -Message "AppX hardening started."

    try {
        # ---------------------------------------------------------
        # Define removable packages by profile
        # ---------------------------------------------------------

        $SafeRemovals = @()   # SAFE removes nothing

        $PowerRemovals = @(
            "Microsoft.3DBuilder",
            "Microsoft.Microsoft3DViewer",
            "Microsoft.MixedReality.Portal",
            "Microsoft.GetHelp",
            "Microsoft.Getstarted"
        )

        $HardcoreRemovals = @(
            "Microsoft.BingNews",
            "Microsoft.BingWeather",
            "Microsoft.MicrosoftOfficeHub",
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.People",
            "Microsoft.SkypeApp",
            "Microsoft.XboxApp",
            "Microsoft.Xbox.TCUI",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.XboxIdentityProvider",
            "Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo"
        )

        # Merge based on profile
        switch ($ProfileSettings.Level) {
            "Safe"     { $RemovablePackages = $SafeRemovals }
            "Power"    { $RemovablePackages = $PowerRemovals }
            "Hardcore" { $RemovablePackages = $PowerRemovals + $HardcoreRemovals }
        }

        # ---------------------------------------------------------
        # Remove packages
        # ---------------------------------------------------------

        foreach ($Pkg in $RemovablePackages) {

            $Exists = Get-AppxPackage -Name $Pkg -AllUsers

            if ($Exists) {
                try {
                    $Exists | Remove-AppxPackage -ErrorAction SilentlyContinue
                    Write-Log -Message "Removed AppX package: $Pkg"
                }
                catch {
                    Write-Log -Message "Failed to remove AppX package: $Pkg"
                }
            }

            # Remove provisioned version
            $Prov = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $Pkg }
            if ($Prov) {
                try {
                    Remove-AppxProvisionedPackage -Online -PackageName $Prov.PackageName -ErrorAction SilentlyContinue
                    Write-Log -Message "Removed provisioned AppX: $Pkg"
                }
                catch {
                    Write-Log -Message "Failed to remove provisioned AppX: $Pkg"
                }
            }
        }

        # ---------------------------------------------------------
        # HARDCORE: block reinstall
        # ---------------------------------------------------------
        if ($ProfileSettings.Level -eq "Hardcore") {

            Write-Host "Applying HARDCORE AppX restrictions..." -ForegroundColor Yellow
            Write-Log -Message "Applying HARDCORE AppX restrictions"

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
                             -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
                             -Name "DisableThirdPartySuggestions" -Value 1 -Type DWord -Force

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
                             -Name "DisableAutomaticAppInstall" -Value 1 -Type DWord -Force
        }

        Write-Host "AppX governance applied." -ForegroundColor Green
        Write-Log -Message "AppX hardening completed successfully."

        return "Success"
    }
    catch {
        Write-Host "AppX hardening failed: $_" -ForegroundColor Red
        Write-Log -Message "AppX hardening error: $_"
        return "Error"
    }
}
