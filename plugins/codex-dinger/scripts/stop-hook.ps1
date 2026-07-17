$ErrorActionPreference = 'Stop'
$continueResponse = '{"continue":true}'

try {
    $rawEvent = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($rawEvent)) {
        throw 'The Stop hook received no JSON on stdin.'
    }

    # Validate the hook payload without retaining user messages or assistant output.
    [void]($rawEvent | ConvertFrom-Json)

    $soundWorker = Join-Path $env:PLUGIN_ROOT 'scripts\play-sound.ps1'
    [void](Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        ('"{0}"' -f $soundWorker)
    ))
}
catch {
    if (-not [string]::IsNullOrWhiteSpace($env:PLUGIN_DATA)) {
        try {
            [void](New-Item -ItemType Directory -Path $env:PLUGIN_DATA -Force)
            $errorPath = Join-Path $env:PLUGIN_DATA 'stop-hook-errors.log'
            $errorLine = ('{0:o} {1}{2}' -f [DateTime]::UtcNow, $_.Exception.Message, [Environment]::NewLine)
            [IO.File]::AppendAllText($errorPath, $errorLine, [Text.UTF8Encoding]::new($false))
        }
        catch { }
    }
}

[Console]::Out.Write($continueResponse)
exit 0
