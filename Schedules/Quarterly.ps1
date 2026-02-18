# Quarterly.ps1
# Quarterly maintenance entry point

param(
    [Parameter(Mandatory = $true)]
    $ProfileSettings
)

. "$PSScriptRoot\..\Engine\Logging.ps1"
. "$PSScriptRoot\..\Engine\Profiles.ps1"
. "$PSScriptRoot\..\Engine\Run.ps1"

Write-Host "Executing QUARTERLY maintenance..." -ForegroundColor Cyan
Write-Log -Message "Quarterly maintenance started. Profile=$($ProfileSettings.Level)"

$score = Invoke-CleanPC -Mode "Quarterly" -ProfileSettings $ProfileSettings

Write-Host "Quarterly maintenance completed." -ForegroundColor Green
Write-Log -Message "Quarterly maintenance completed. Score=$score"
