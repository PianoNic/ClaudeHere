# ClaudeHere uninstaller — removes registry entries and the installed icon.

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Pause-Countdown {
    param([int]$Seconds = 5, [string]$Color = 'Gray')
    for ($i = $Seconds; $i -gt 0; $i--) {
        Write-Host "`rClosing in $i seconds... (press any key to close now) " -NoNewline -ForegroundColor $Color
        if ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            break
        }
        Start-Sleep -Seconds 1
    }
    Write-Host ''
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$scriptPath`"")
    try {
        Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList -ErrorAction Stop
    } catch {
        Write-Host "Elevation cancelled or failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "ClaudeHere needs admin rights to remove the context-menu entries." -ForegroundColor Yellow
        Pause-Countdown -Seconds 5 -Color Yellow
        exit 1
    }
    exit 0
}

$ErrorActionPreference = 'Stop'
$exitCode = 0

try {
    Get-ChildItem -Path $here -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue

    $regFile = Join-Path $here 'uninstall.reg'
    if (-not (Test-Path $regFile)) {
        throw "Registry file not found at $regFile."
    }
    Write-Host "Importing $regFile ..."
    $proc = Start-Process -FilePath 'reg.exe' -ArgumentList @('import', "`"$regFile`"") -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        throw "reg.exe import failed with exit code $($proc.ExitCode)."
    }

    $iconDir = Join-Path $env:LOCALAPPDATA 'ClaudeHere'
    if (Test-Path $iconDir) {
        Remove-Item -Recurse -Force $iconDir
        Write-Host "Removed $iconDir" -ForegroundColor Green
    }

    Write-Host ''
    Write-Host "ClaudeHere uninstalled." -ForegroundColor Green
    Pause-Countdown -Seconds 5 -Color Gray
} catch {
    Write-Host ''
    Write-Host "Uninstall failed: $($_.Exception.Message)" -ForegroundColor Red
    Pause-Countdown -Seconds 5 -Color Yellow
    $exitCode = 1
}

exit $exitCode
