# ClaudeHere installer
# Copies claude.ico to %LOCALAPPDATA%\ClaudeHere\ and imports the chosen .reg file.

param(
    [ValidateSet('safe', 'yolo')]
    [string]$Variant = 'safe'
)

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

# Self-elevate: importing into HKEY_CLASSES_ROOT writes to HKLM, which needs admin.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$scriptPath`"", '-Variant', $Variant)
    try {
        Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList -ErrorAction Stop
    } catch {
        Write-Host "Elevation cancelled or failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "ClaudeHere needs admin rights to write the context-menu entries." -ForegroundColor Yellow
        Pause-Countdown -Seconds 5 -Color Yellow
        exit 1
    }
    exit 0
}

$ErrorActionPreference = 'Stop'
$exitCode = 0

try {
    # Strip Mark-of-the-Web from anything we ship, in case the user downloaded a ZIP.
    Get-ChildItem -Path $here -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue

    $iconSource = Join-Path $here 'assets\claude.ico'
    if (-not (Test-Path $iconSource)) {
        throw "Icon not found at $iconSource. Run this script from inside the ClaudeHere folder."
    }

    $iconDir = Join-Path $env:LOCALAPPDATA 'ClaudeHere'
    New-Item -ItemType Directory -Force -Path $iconDir | Out-Null
    Copy-Item -Force -Path $iconSource -Destination (Join-Path $iconDir 'claude.ico')
    Write-Host "Icon installed to $iconDir\claude.ico" -ForegroundColor Green

    $regFile = Join-Path $here "install-$Variant.reg"
    if (-not (Test-Path $regFile)) {
        throw "Registry file not found at $regFile."
    }
    Write-Host "Importing $regFile ..."
    $proc = Start-Process -FilePath 'reg.exe' -ArgumentList @('import', "`"$regFile`"") -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        throw "reg.exe import failed with exit code $($proc.ExitCode)."
    }

    Write-Host ''
    Write-Host "Installed the '$Variant' variant." -ForegroundColor Green
    Write-Host "Right-click any folder in Explorer (Windows 11: 'Show more options') to see 'Open Claude here'."
    Pause-Countdown -Seconds 5 -Color Gray
} catch {
    Write-Host ''
    Write-Host "Install failed: $($_.Exception.Message)" -ForegroundColor Red
    Pause-Countdown -Seconds 5 -Color Yellow
    $exitCode = 1
}

exit $exitCode
