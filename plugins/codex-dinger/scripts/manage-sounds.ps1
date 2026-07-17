param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Status', 'List', 'Add', 'Select', 'Preview', 'Remove', 'Volume', 'Enable', 'Disable')]
    [string]$Action,
    [string]$Path,
    [string]$Name,
    [ValidateRange(0, 100)]
    [int]$Value,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$dataRoot = if (-not [string]::IsNullOrWhiteSpace($env:CODEX_DINGER_DATA)) { $env:CODEX_DINGER_DATA } else { Join-Path $env:LOCALAPPDATA 'CodexDinger' }
$bankPath = Join-Path $dataRoot 'sounds'
$settingsPath = Join-Path $dataRoot 'settings.json'
$pluginRoot = Split-Path -Parent $PSScriptRoot
$playerPath = Join-Path $PSScriptRoot 'play-sound.ps1'
$defaultSoundPath = Join-Path $pluginRoot 'assets\default-chime.wav'
$allowedExtensions = @('.wav', '.mp3', '.wma', '.m4a')
$maximumBytes = 25MB

function Get-Settings {
    $settings = [ordered]@{ version = 1; enabled = $true; volume = 65; activeSound = $null }
    if (Test-Path -LiteralPath $settingsPath) {
        $saved = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
        if ($null -ne $saved.enabled) { $settings.enabled = [bool]$saved.enabled }
        if ($null -ne $saved.volume) { $settings.volume = [int]$saved.volume }
        if ($null -ne $saved.activeSound) { $settings.activeSound = [string]$saved.activeSound }
    }
    return $settings
}

function Save-Settings([System.Collections.IDictionary]$Settings) {
    [void](New-Item -ItemType Directory -Path $dataRoot -Force)
    $temporaryPath = "$settingsPath.tmp"
    $Settings | ConvertTo-Json | Set-Content -LiteralPath $temporaryPath -Encoding UTF8
    Move-Item -LiteralPath $temporaryPath -Destination $settingsPath -Force
}

function Get-BankSound([string]$SoundName) {
    if ([string]::IsNullOrWhiteSpace($SoundName)) { throw 'A sound name is required.' }
    if ($SoundName -ne [IO.Path]::GetFileName($SoundName)) { throw 'Sound names cannot contain a path.' }
    $candidate = Join-Path $bankPath $SoundName
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { throw "Sound not found in bank: $SoundName" }
    return $candidate
}

$settings = Get-Settings

switch ($Action) {
    'Status' {
        [pscustomobject]@{ enabled = $settings.enabled; volume = $settings.volume; activeSound = $(if ($settings.activeSound) { $settings.activeSound } else { 'default' }); dataRoot = $dataRoot } | ConvertTo-Json
    }
    'List' {
        [pscustomobject]@{ name = 'default'; active = [string]::IsNullOrWhiteSpace($settings.activeSound); bundled = $true }
        if (Test-Path -LiteralPath $bankPath) {
            Get-ChildItem -LiteralPath $bankPath -File | Where-Object { $allowedExtensions -contains $_.Extension.ToLowerInvariant() } | Sort-Object Name | ForEach-Object {
                [pscustomobject]@{ name = $_.Name; active = ($settings.activeSound -eq $_.Name); bundled = $false }
            }
        }
    }
    'Add' {
        if ([string]::IsNullOrWhiteSpace($Path)) { throw 'Add requires -Path.' }
        $source = Get-Item -LiteralPath $Path
        if ($source.PSIsContainer) { throw 'The source must be an audio file.' }
        if ($allowedExtensions -notcontains $source.Extension.ToLowerInvariant()) { throw "Unsupported audio type: $($source.Extension)" }
        if ($source.Length -gt $maximumBytes) { throw 'Audio files must be 25 MB or smaller.' }
        $safeName = $source.Name
        [void](New-Item -ItemType Directory -Path $bankPath -Force)
        $destination = Join-Path $bankPath $safeName
        if ((Test-Path -LiteralPath $destination) -and -not $Force) { throw "A sound named '$safeName' already exists. Confirm overwrite, then pass -Force." }
        Copy-Item -LiteralPath $source.FullName -Destination $destination -Force:$Force
        Write-Output "Added: $safeName"
    }
    'Select' {
        if ($Name -eq 'default') { $settings.activeSound = $null } else { [void](Get-BankSound $Name); $settings.activeSound = $Name }
        Save-Settings $settings
        Write-Output "Active sound: $(if ($settings.activeSound) { $settings.activeSound } else { 'default' })"
    }
    'Preview' {
        $previewPath = if ($Name -eq 'default' -or [string]::IsNullOrWhiteSpace($Name)) { $defaultSoundPath } else { Get-BankSound $Name }
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $playerPath -SoundPath $previewPath -Volume $settings.volume
    }
    'Remove' {
        $sound = Get-BankSound $Name
        if (-not $Force) { throw "Confirm removal of '$Name', then pass -Force." }
        Remove-Item -LiteralPath $sound -Force
        if ($settings.activeSound -eq $Name) { $settings.activeSound = $null; Save-Settings $settings }
        Write-Output "Removed: $Name"
    }
    'Volume' {
        if (-not $PSBoundParameters.ContainsKey('Value')) { throw 'Volume requires -Value from 0 to 100.' }
        $settings.volume = $Value
        Save-Settings $settings
        Write-Output "Volume: $Value%"
    }
    'Enable' { $settings.enabled = $true; Save-Settings $settings; Write-Output 'Codex Dinger enabled.' }
    'Disable' { $settings.enabled = $false; Save-Settings $settings; Write-Output 'Codex Dinger disabled.' }
}
