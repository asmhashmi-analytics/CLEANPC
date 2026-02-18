# Weekly.ps1
# Weekly maintenance entry point

param(
    [Parameter(Mandatory = $true)]
    $ProfileSettings
)

. "$PSScriptRoot\..\Engine\Logging.ps1"
. "$PSScriptRoot\..\Engine\Profiles.ps1"
. "$PSScriptRoot\..\Engine\Run.ps1"

Write-Host "Executing WEEKLY maintenance..." -ForegroundColor Cyan
Write-Log -Message "Weekly maintenance started. Profile=$($ProfileSettings.Level)"

$score = Invoke-CleanPC -Mode "Weekly" -ProfileSettings $ProfileSettings

Write-Host "Weekly maintenance completed." -ForegroundColor Green
Write-Log -Message "Weekly maintenance completed. Score=$score"
