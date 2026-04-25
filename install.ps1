# ClaudeHere installer
# Copies claude.ico to %LOCALAPPDATA%\ClaudeHere\, imports the chosen .reg file,
# and localizes the menu entries to the OS UI language.

param(
    [ValidateSet('safe', 'yolo')]
    [string]$Variant,
    [string]$Language
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Translations live in translations.xml — see that file to add a language.
$translationsFile = Join-Path $here 'translations.xml'
if (-not (Test-Path $translationsFile)) {
    Write-Host "translations.xml not found at $translationsFile" -ForegroundColor Red
    exit 1
}
$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.Load($translationsFile)
$translations = @{}
foreach ($lang in $xmlDoc.translations.language) {
    $translations[$lang.code] = @($lang.GetAttribute('open'), $lang.GetAttribute('continue'))
}

function Resolve-LanguageKey {
    param([string]$Culture)
    if ([string]::IsNullOrWhiteSpace($Culture)) { return 'en' }
    $c = $Culture.Trim()
    # Chinese: differentiate Simplified vs Traditional
    if ($c -match '^zh-(Hans|CN|SG|MY)') { return 'zh-Hans' }
    if ($c -match '^zh-(Hant|TW|HK|MO)') { return 'zh-Hant' }
    if ($c -match '^zh') { return 'zh-Hans' }
    # Norwegian variants
    if ($c -match '^(nb|nn|no)') { return 'nb' }
    # Filipino
    if ($c -match '^(fil|tl)') { return 'fil' }
    $primary = $c.Split('-')[0].ToLowerInvariant()
    if ($translations.ContainsKey($primary)) { return $primary }
    return 'en'
}

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

# Interactive prompt if -Variant was not passed (e.g. double-click).
if (-not $PSBoundParameters.ContainsKey('Variant')) {
    Write-Host ''
    Write-Host 'ClaudeHere installer' -ForegroundColor Cyan
    Write-Host '--------------------'
    Write-Host '  [1] safe   - runs `claude` (keeps per-tool permission prompts, recommended)'
    Write-Host '  [2] yolo   - runs `claude --dangerously-skip-permissions` (skips prompts, use with care)'
    Write-Host ''
    do {
        $choice = Read-Host 'Pick a variant [1/2] (default 1)'
        if ([string]::IsNullOrWhiteSpace($choice)) { $choice = '1' }
        switch ($choice.Trim().ToLower()) {
            { $_ -in '1', 'safe', 's' } { $Variant = 'safe' }
            { $_ -in '2', 'yolo', 'y' } { $Variant = 'yolo' }
            default { Write-Host "Unknown choice '$choice'. Type 1 or 2." -ForegroundColor Yellow; $Variant = $null }
        }
    } while (-not $Variant)
    Write-Host "Selected: $Variant" -ForegroundColor Green
    Write-Host ''
}

# Resolve language (auto-detect from OS UI culture unless -Language is given)
if ([string]::IsNullOrWhiteSpace($Language)) {
    $Language = [Globalization.CultureInfo]::CurrentUICulture.Name
}
$langKey = Resolve-LanguageKey -Culture $Language

# Self-elevate: importing into HKEY_CLASSES_ROOT writes to HKLM, which needs admin.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$scriptPath`"", '-Variant', $Variant, '-Language', $Language)
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

    $regFile = Join-Path $here "reg\install-$Variant.reg"
    if (-not (Test-Path $regFile)) {
        throw "Registry file not found at $regFile."
    }
    Write-Host "Importing $regFile ..."
    $proc = Start-Process -FilePath 'reg.exe' -ArgumentList @('import', "`"$regFile`"") -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        throw "reg.exe import failed with exit code $($proc.ExitCode)."
    }

    # Localize the menu labels (Unicode-safe via .NET registry API).
    $strings = $translations[$langKey]
    Write-Host "Localizing menu entries: $langKey ($Language) -> '$($strings[0])' / '$($strings[1])'"
    $keys = @(
        @{ Path = 'Directory\shell\ClaudeHere';                    Text = $strings[0] },
        @{ Path = 'Directory\shell\ClaudeHereContinue';            Text = $strings[1] },
        @{ Path = 'Directory\Background\shell\ClaudeHere';         Text = $strings[0] },
        @{ Path = 'Directory\Background\shell\ClaudeHereContinue'; Text = $strings[1] },
        @{ Path = 'Drive\shell\ClaudeHere';                        Text = $strings[0] },
        @{ Path = 'Drive\shell\ClaudeHereContinue';                Text = $strings[1] }
    )
    foreach ($k in $keys) {
        $regKey = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey($k.Path, $true)
        if ($null -eq $regKey) { throw "Registry key not found: $($k.Path)" }
        $regKey.SetValue('', $k.Text, [Microsoft.Win32.RegistryValueKind]::String)
        $regKey.Close()
    }

    Write-Host ''
    Write-Host "Installed the '$Variant' variant in language '$langKey'." -ForegroundColor Green
    Write-Host "Right-click any folder in Explorer (Windows 11: 'Show more options') to see the entry."
    Pause-Countdown -Seconds 5 -Color Gray
} catch {
    Write-Host ''
    Write-Host "Install failed: $($_.Exception.Message)" -ForegroundColor Red
    Pause-Countdown -Seconds 5 -Color Yellow
    $exitCode = 1
}

exit $exitCode
