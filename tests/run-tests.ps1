$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $repoRoot 'plugins\codex-dinger'
$manager = Join-Path $pluginRoot 'scripts\manage-sounds.ps1'
$fixture = Join-Path $pluginRoot 'assets\default-chime.wav'
$testRoot = Join-Path $env:TEMP ("codex-dinger-tests-" + [Guid]::NewGuid().ToString('N'))

try {
    $env:CODEX_DINGER_DATA = $testRoot
    $status = (& $manager -Action Status | ConvertFrom-Json)
    if (-not $status.enabled -or $status.volume -ne 65 -or $status.activeSound -ne 'default') { throw 'Default settings test failed.' }

    & $manager -Action Add -Path $fixture | Out-Null
    & $manager -Action Select -Name 'default-chime.wav' | Out-Null
    & $manager -Action Volume -Value 42 | Out-Null
    $status = (& $manager -Action Status | ConvertFrom-Json)
    if ($status.activeSound -ne 'default-chime.wav' -or $status.volume -ne 42) { throw 'Selection or volume test failed.' }

    & $manager -Action Disable | Out-Null
    $status = (& $manager -Action Status | ConvertFrom-Json)
    if ($status.enabled) { throw 'Disable test failed.' }

    & $manager -Action Remove -Name 'default-chime.wav' -Force | Out-Null
    $status = (& $manager -Action Status | ConvertFrom-Json)
    if ($status.activeSound -ne 'default') { throw 'Removing the active sound did not restore the default.' }

    Write-Output 'All Codex Dinger tests passed.'
}
finally {
    Remove-Item Env:CODEX_DINGER_DATA -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
}
