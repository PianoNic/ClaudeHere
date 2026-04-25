# ClaudeHere uninstaller — removes registry entries and the installed icon.

$ErrorActionPreference = 'SilentlyContinue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

reg.exe import (Join-Path $here 'uninstall.reg')

$iconDir = Join-Path $env:LOCALAPPDATA 'ClaudeHere'
if (Test-Path $iconDir) {
    Remove-Item -Recurse -Force $iconDir
    Write-Host "Removed $iconDir"
}
Write-Host "Done."
