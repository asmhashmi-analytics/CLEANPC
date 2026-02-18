# AsNeeded.ps1
# On-demand maintenance entry point

param(
    [Parameter(Mandatory = $true)]
    $ProfileSettings
)

. "$PSScriptRoot\..\Engine\Logging.ps1"
. "$PSScriptRoot\..\Engine\Profiles.ps1"
. "$PSScriptRoot\..\Engine\Run.ps1"

Write-Host "Executing AS-NEEDED maintenance..." -ForegroundColor Cyan
Write-Log -Message "As-Needed maintenance started. Profile=$($ProfileSettings.Level)"

$score = Invoke-CleanPC -Mode "AsNeeded" -ProfileSettings $ProfileSettings

Write-Host "As-Needed maintenance completed." -ForegroundColor Green
Write-Log -Message "As-Needed maintenance completed. Score=$score"
