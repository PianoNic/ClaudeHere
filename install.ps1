# ClaudeHere installer
# Copies claude.ico to %LOCALAPPDATA%\ClaudeHere\ and imports the chosen .reg file.

param(
    [ValidateSet('safe', 'yolo')]
    [string]$Variant = 'safe'
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Self-elevate: importing into HKEY_CLASSES_ROOT writes to HKLM, which needs admin.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$scriptPath`"", '-Variant', $Variant)
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList
    exit
}

$iconDir = Join-Path $env:LOCALAPPDATA 'ClaudeHere'
New-Item -ItemType Directory -Force -Path $iconDir | Out-Null
Copy-Item -Force -Path (Join-Path $here 'assets\claude.ico') -Destination (Join-Path $iconDir 'claude.ico')
Write-Host "Icon installed to $iconDir\claude.ico"

$regFile = Join-Path $here "install-$Variant.reg"
Write-Host "Importing $regFile ..."
reg.exe import $regFile
Write-Host "Done. Right-click any folder (Windows 11: 'Show more options') to see 'Open Claude here'."
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
