$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$updater = Join-Path $repoRoot 'plugins\codex-dinger\scripts\update-plugin.ps1'
$testRoot = Join-Path $env:TEMP ("codex-dinger-update-tests-" + [Guid]::NewGuid().ToString('N'))
$marketPlugin = Join-Path $testRoot 'marketplace\plugins\codex-dinger'
$manifestDirectory = Join-Path $marketPlugin '.codex-plugin'
$manifestPath = Join-Path $manifestDirectory 'plugin.json'
$statePath = Join-Path $testRoot 'installed-version.txt'
$fakeCliPath = Join-Path $testRoot 'codex-test-double.ps1'

try {
    [void](New-Item -ItemType Directory -Path $manifestDirectory -Force)
    '{"name":"codex-dinger","version":"0.2.0"}' | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    '0.1.0' | Set-Content -LiteralPath $statePath -Encoding ASCII

    @'
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$CliArguments)

if ($CliArguments[0] -eq 'plugin' -and $CliArguments[1] -eq 'list') {
    $version = (Get-Content -LiteralPath $env:CODEX_DINGER_FAKE_STATE -Raw).Trim()
    [pscustomobject]@{
        installed = @([pscustomobject]@{
            pluginId = 'codex-dinger@codex-dinger'
            name = 'codex-dinger'
            marketplaceName = 'codex-dinger'
            version = $version
            installed = $true
            enabled = $true
            source = [pscustomobject]@{ source = 'local'; path = $env:CODEX_DINGER_FAKE_PLUGIN }
            marketplaceSource = [pscustomobject]@{ sourceType = 'git'; source = 'https://example.invalid/Codex-Dinger.git' }
        })
        available = @()
    } | ConvertTo-Json -Depth 10
}
elseif ($CliArguments[0] -eq 'plugin' -and $CliArguments[1] -eq 'marketplace' -and $CliArguments[2] -eq 'upgrade') {
    '{}'
}
elseif ($CliArguments[0] -eq 'plugin' -and $CliArguments[1] -eq 'add') {
    $manifest = Get-Content -LiteralPath (Join-Path $env:CODEX_DINGER_FAKE_PLUGIN '.codex-plugin\plugin.json') -Raw | ConvertFrom-Json
    $manifest.version | Set-Content -LiteralPath $env:CODEX_DINGER_FAKE_STATE -Encoding ASCII
    '{}'
}
else {
    throw "Unexpected fake CLI arguments: $($CliArguments -join ' ')"
}

$global:LASTEXITCODE = 0
'@ | Set-Content -LiteralPath $fakeCliPath -Encoding UTF8

    $oldCliPath = $env:CODEX_CLI_PATH
    $env:CODEX_CLI_PATH = $fakeCliPath
    $env:CODEX_DINGER_FAKE_STATE = $statePath
    $env:CODEX_DINGER_FAKE_PLUGIN = $marketPlugin

    $checkOutput = (& $updater -Action Check) -join "`n"
    if ($checkOutput -notmatch '0\.2\.0 is available' -or (Get-Content $statePath -Raw).Trim() -ne '0.1.0') {
        throw 'Check-only update test failed.'
    }

    $updateOutput = (& $updater -Action Update) -join "`n"
    if ($updateOutput -notmatch 'from 0\.1\.0 to 0\.2\.0' -or (Get-Content $statePath -Raw).Trim() -ne '0.2.0') {
        throw 'Update installation test failed.'
    }

    Write-Output 'Codex Dinger updater tests passed.'
}
finally {
    if ($null -eq $oldCliPath) { Remove-Item Env:CODEX_CLI_PATH -ErrorAction SilentlyContinue } else { $env:CODEX_CLI_PATH = $oldCliPath }
    Remove-Item Env:CODEX_DINGER_FAKE_STATE -ErrorAction SilentlyContinue
    Remove-Item Env:CODEX_DINGER_FAKE_PLUGIN -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
}
