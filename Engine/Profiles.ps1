# Profiles.ps1
# CLEANPC Profile Definitions (Modernised for UX-driven cadence selection)

function Get-CleanPCProfile {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("SAFE","POWER","HARDCORE")]
        [string]$Profile
    )

    switch ($Profile.ToUpper()) {

        "SAFE" {
            return @{
                Name  = "SAFE"
                Level = "Safe"

                # Hardening
                Hardening = $false

                # Storage Modules
                SSDHealth = $true
                TRIM      = $true
                SMART     = $false

                # Component Store Behaviour
                ComponentStoreCheck  = $true
                ComponentStoreRepair = $false
            }
        }

        "POWER" {
            return @{
                Name  = "POWER"
                Level = "Power"

                # Hardening
                Hardening = $true

                # Storage Modules
                SSDHealth = $true
                TRIM      = $true
                SMART     = $true

                # Component Store Behaviour
                ComponentStoreCheck  = $true
                ComponentStoreRepair = $true
            }
        }

        "HARDCORE" {
            return @{
                Name  = "HARDCORE"
                Level = "Hardcore"

                # Hardening
                Hardening = $true

                # Storage Modules
                SSDHealth = $true
                TRIM      = $true
                SMART     = $true

                # Component Store Behaviour
                ComponentStoreCheck  = $true
                ComponentStoreRepair = $true
            }
        }
    }
}
