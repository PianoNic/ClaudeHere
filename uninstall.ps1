# ClaudeHere uninstaller — removes registry entries and the installed icon.

$ErrorActionPreference = 'SilentlyContinue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$scriptPath`"")
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList
    exit
}

reg.exe import (Join-Path $here 'uninstall.reg')

$iconDir = Join-Path $env:LOCALAPPDATA 'ClaudeHere'
if (Test-Path $iconDir) {
    Remove-Item -Recurse -Force $iconDir
    Write-Host "Removed $iconDir"
}
Write-Host "Done."
