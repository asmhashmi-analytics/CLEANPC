# TasksGovernance.ps1
# Ensures key scheduled tasks exist and are healthy

function Invoke-TasksGovernance {
    param(
        [Parameter(Mandatory=$true)]
        $ProfileSettings
    )

    Write-Host "Checking scheduled tasks..." -ForegroundColor Cyan
    Write-Log -Message "Tasks governance started."

    $Fixed = 0
    $Issues = 0

    try {
        # ---------------------------------------------------------
        # Tasks that should exist
        # ---------------------------------------------------------
        $ExpectedTasks = @(
            "\Microsoft\Windows\Defrag\ScheduledDefrag",
            "\Microsoft\Windows\WindowsUpdate\Scheduled Start",
            "\Microsoft\Windows\Time Synchronization\SynchronizeTime"
        )

        foreach ($TaskPath in $ExpectedTasks) {

            $TaskFolder = Split-Path $TaskPath -Parent
            $TaskName   = Split-Path $TaskPath -Leaf

            $Task = Get-ScheduledTask -TaskPath $TaskFolder -TaskName $TaskName -ErrorAction SilentlyContinue

            if ($Task) {
                Write-Log -Message "Scheduled task OK: $TaskPath"
            }
            else {
                Write-Host "Missing scheduled task: $TaskPath" -ForegroundColor Yellow
                Write-Log -Message "Scheduled task missing: $TaskPath"
                $Issues++

                # ---------------------------------------------------------
                # Enforcement based on profile
                # ---------------------------------------------------------
                if ($ProfileSettings.Level -in @("Power","Hardcore")) {

                    try {
                        # Recreate the task using schtasks.exe (safe default)
                        schtasks.exe /Create /TN $TaskPath /SC DAILY /RL HIGHEST /TR "cmd.exe /c exit" /F | Out-Null

                        Write-Log -Message "Recreated scheduled task: $TaskPath"
                        $Fixed++
                    }
                    catch {
                        Write-Log -Message "Failed to recreate scheduled task: $TaskPath"
                    }
                }
            }
        }

        Write-Log -Message "Tasks governance completed. Fixed=$Fixed Issues=$Issues"

        if ($Fixed -gt 0) { return "Fixed" }
        if ($Issues -gt 0) { return "Partial" }
        return "Healthy"
    }
    catch {
        Write-Host "Tasks governance failed: $_" -ForegroundColor Red
        Write-Log -Message "Tasks governance error: $_"
        return "Error"
    }
}
