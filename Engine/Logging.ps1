# Logging.ps1
# CLEANPC Logging Module (Enterprise-Grade)

# ---------------------------------------------------------
# Global Log Path
# ---------------------------------------------------------

$Global:CleanPCLogDirectory = "C:\cleanpc"
$Global:CleanPCLogPath      = Join-Path $Global:CleanPCLogDirectory "cleanpc.log"
$Global:CleanPCLogMaxSizeMB = 5

# ---------------------------------------------------------
# Ensure Log Directory Exists
# ---------------------------------------------------------

if (-not (Test-Path $Global:CleanPCLogDirectory)) {
    New-Item -ItemType Directory -Path $Global:CleanPCLogDirectory | Out-Null
}

# ---------------------------------------------------------
# Rotate Log if Too Large
# ---------------------------------------------------------

function Rotate-Log {
    if (Test-Path $Global:CleanPCLogPath) {
        $SizeMB = (Get-Item $Global:CleanPCLogPath).Length / 1MB

        if ($SizeMB -ge $Global:CleanPCLogMaxSizeMB) {
            $Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
            $ArchivePath = Join-Path $Global:CleanPCLogDirectory "cleanpc_$Timestamp.log"
            Rename-Item -Path $Global:CleanPCLogPath -NewName $ArchivePath
        }
    }
}

# ---------------------------------------------------------
# Write Log Entry
# ---------------------------------------------------------

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    try {
        Rotate-Log

        $Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $Entry = "$Timestamp [$Level] $Message"

        Add-Content -Path $Global:CleanPCLogPath -Value $Entry
    }
    catch {
        Write-Host "Failed to write to log: $_" -ForegroundColor Red
    }
}
