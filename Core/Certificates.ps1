# Certificates.ps1
# Checks certificate store health and logs issues

function Invoke-CertificateCheck {
    param(
        [Parameter(Mandatory=$true)]
        $ProfileSettings
    )

    Write-Host "Checking certificate store health..." -ForegroundColor Cyan
    Write-Log -Message "Certificate check started."

    $ExpiredCount = 0
    $ExpiringSoonCount = 0
    $UntrustedCount = 0

    try {
        $Now = Get-Date
        $WarningThreshold = $Now.AddDays(30)

        # Stores to check
        $Stores = @(
            "Cert:\LocalMachine\Root",
            "Cert:\LocalMachine\My",
            "Cert:\LocalMachine\TrustedPeople",
            "Cert:\LocalMachine\TrustedPublisher"
        )

        foreach ($Store in $Stores) {

            Write-Log -Message "Scanning certificate store: $Store"

            $Certs = Get-ChildItem -Path $Store -ErrorAction SilentlyContinue

            if (-not $Certs) {
                Write-Log -Message "No certificates found or store inaccessible: $Store"
                continue
            }

            foreach ($Cert in $Certs) {

                # Expired certificates
                if ($Cert.NotAfter -lt $Now) {
                    $ExpiredCount++
                    Write-Host "Expired certificate: $($Cert.Subject)" -ForegroundColor Yellow
                    Write-Log -Message "Expired certificate: $($Cert.Subject) | Expired: $($Cert.NotAfter)"
                }

                # Certificates expiring soon
                elseif ($Cert.NotAfter -lt $WarningThreshold) {
                    $ExpiringSoonCount++
                    Write-Host "Certificate expiring soon: $($Cert.Subject)" -ForegroundColor Yellow
                    Write-Log -Message "Certificate expiring soon: $($Cert.Subject) | Expires: $($Cert.NotAfter)"
                }

                # Untrusted root detection
                if ($Store -eq "Cert:\LocalMachine\Root" -and -not $Cert.Verify()) {
                    $UntrustedCount++
                    Write-Host "Untrusted root certificate: $($Cert.Subject)" -ForegroundColor Yellow
                    Write-Log -Message "Untrusted root certificate: $($Cert.Subject)"
                }
            }
        }

        Write-Log -Message "Certificate check completed. Expired=$ExpiredCount ExpiringSoon=$ExpiringSoonCount Untrusted=$UntrustedCount"
        Write-Host "Certificate store check completed." -ForegroundColor Green

        # Return structured result
        if ($ExpiredCount -gt 0 -or $UntrustedCount -gt 0) { return "Issues" }
        if ($ExpiringSoonCount -gt 0) { return "Warning" }
        return "Healthy"
    }
    catch {
        Write-Host "Certificate check failed: $_" -ForegroundColor Red
        Write-Log -Message "Certificate check error: $_"
        return "Error"
    }
}
