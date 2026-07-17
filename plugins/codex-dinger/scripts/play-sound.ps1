param(
    [string]$SoundPath,
    [Nullable[double]]$Volume
)

$ErrorActionPreference = 'Stop'

try {
    Add-Type -AssemblyName PresentationCore

    $dataRoot = if (-not [string]::IsNullOrWhiteSpace($env:CODEX_DINGER_DATA)) {
        $env:CODEX_DINGER_DATA
    }
    else {
        Join-Path $env:LOCALAPPDATA 'CodexDinger'
    }

    $settings = [ordered]@{ enabled = $true; volume = 65; activeSound = $null }
    $settingsPath = Join-Path $dataRoot 'settings.json'
    if (Test-Path -LiteralPath $settingsPath) {
        $saved = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
        if ($null -ne $saved.enabled) { $settings.enabled = [bool]$saved.enabled }
        if ($null -ne $saved.volume) { $settings.volume = [int]$saved.volume }
        if ($null -ne $saved.activeSound) { $settings.activeSound = [string]$saved.activeSound }
    }

    if (-not $settings.enabled -and [string]::IsNullOrWhiteSpace($SoundPath)) { exit 0 }

    if ([string]::IsNullOrWhiteSpace($SoundPath)) {
        if (-not [string]::IsNullOrWhiteSpace($settings.activeSound)) {
            $candidate = Join-Path (Join-Path $dataRoot 'sounds') $settings.activeSound
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $SoundPath = $candidate }
        }
        if ([string]::IsNullOrWhiteSpace($SoundPath)) {
            $SoundPath = Join-Path $env:PLUGIN_ROOT 'assets\default-chime.wav'
        }
    }

    if (-not (Test-Path -LiteralPath $SoundPath -PathType Leaf)) {
        throw "Sound file not found: $SoundPath"
    }

    $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
    $volumePercent = if ($null -ne $Volume) { [double]$Volume } else { [double]$settings.volume }
    $mediaPlayer.Volume = [Math]::Max(0, [Math]::Min(100, $volumePercent)) / 100
    $mediaPlayer.Open([Uri]::new((Resolve-Path -LiteralPath $SoundPath).Path))

    $openDeadline = [DateTime]::UtcNow.AddSeconds(5)
    while (-not $mediaPlayer.NaturalDuration.HasTimeSpan -and [DateTime]::UtcNow -lt $openDeadline) {
        Start-Sleep -Milliseconds 50
    }

    $mediaPlayer.Play()
    $playbackMilliseconds = if ($mediaPlayer.NaturalDuration.HasTimeSpan) {
        [Math]::Ceiling($mediaPlayer.NaturalDuration.TimeSpan.TotalMilliseconds) + 250
    }
    else { 5000 }

    Start-Sleep -Milliseconds $playbackMilliseconds
    $mediaPlayer.Stop()
    $mediaPlayer.Close()
}
catch {
    if (-not [string]::IsNullOrWhiteSpace($env:PLUGIN_DATA)) {
        try {
            [void](New-Item -ItemType Directory -Path $env:PLUGIN_DATA -Force)
            $errorPath = Join-Path $env:PLUGIN_DATA 'sound-errors.log'
            $errorLine = ('{0:o} {1}{2}' -f [DateTime]::UtcNow, $_.Exception.Message, [Environment]::NewLine)
            [IO.File]::AppendAllText($errorPath, $errorLine, [Text.UTF8Encoding]::new($false))
        }
        catch { }
    }
}
