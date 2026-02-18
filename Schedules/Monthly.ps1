# Monthly.ps1
# Monthly maintenance entry point

param(
    [Parameter(Mandatory = $true)]
    $ProfileSettings
)

. "$PSScriptRoot\..\Engine\Logging.ps1"
. "$PSScriptRoot\..\Engine\Profiles.ps1"
. "$PSScriptRoot\..\Engine\Run.ps1"

Write-Host "Executing MONTHLY maintenance..." -ForegroundColor Cyan
Write-Log -Message "Monthly maintenance started. Profile=$($ProfileSettings.Level)"

$score = Invoke-CleanPC -Mode "Monthly" -ProfileSettings $ProfileSettings

Write-Host "Monthly maintenance completed." -ForegroundColor Green
Write-Log -Message "Monthly maintenance completed. Score=$score"
