param(
    [ValidateSet('Check', 'Update')]
    [string]$Action = 'Check'
)

$ErrorActionPreference = 'Stop'
$pluginId = 'codex-dinger@codex-dinger'
$marketplaceName = 'codex-dinger'

function Get-CodexCli {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_CLI_PATH) -and (Test-Path -LiteralPath $env:CODEX_CLI_PATH -PathType Leaf)) {
        return $env:CODEX_CLI_PATH
    }

    $command = Get-Command codex.exe -ErrorAction SilentlyContinue
    if ($null -eq $command) { $command = Get-Command codex -ErrorAction SilentlyContinue }
    if ($null -eq $command) { throw 'Codex CLI was not found. Open Codex and try again.' }
    return $command.Source
}

function Invoke-Codex([string[]]$Arguments) {
    $output = & $script:codexCli @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw (($output | Out-String).Trim()) }
    return $output
}

function Get-PluginState {
    $json = Invoke-Codex @('plugin', 'list', '--marketplace', $marketplaceName, '--available', '--json')
    $state = ($json | Out-String) | ConvertFrom-Json
    $installed = @($state.installed) | Where-Object { $_.pluginId -eq $pluginId } | Select-Object -First 1
    if ($null -eq $installed) { throw "Codex Dinger is not installed from the '$marketplaceName' marketplace." }

    $manifestPath = Join-Path $installed.source.path '.codex-plugin\plugin.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "Marketplace manifest not found: $manifestPath" }
    $availableVersion = (Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json).version

    return [pscustomobject]@{
        InstalledVersion = [string]$installed.version
        AvailableVersion = [string]$availableVersion
    }
}

function Compare-Version([string]$Installed, [string]$Available) {
    $installedCore = ($Installed -split '[-+]')[0]
    $availableCore = ($Available -split '[-+]')[0]
    return ([version]$availableCore).CompareTo([version]$installedCore)
}

$script:codexCli = Get-CodexCli
$before = Get-PluginState
[void](Invoke-Codex @('plugin', 'marketplace', 'upgrade', $marketplaceName, '--json'))
$after = Get-PluginState
$comparison = Compare-Version $before.InstalledVersion $after.AvailableVersion

if ($comparison -le 0) {
    Write-Output "Codex Dinger is current (version $($before.InstalledVersion))."
    exit 0
}

if ($Action -eq 'Check') {
    Write-Output "Codex Dinger $($after.AvailableVersion) is available; installed version is $($before.InstalledVersion)."
    Write-Output 'Ask Codex to update Codex Dinger to install it.'
    exit 0
}

[void](Invoke-Codex @('plugin', 'add', $pluginId, '--json'))
$updated = Get-PluginState
Write-Output "Updated Codex Dinger from $($before.InstalledVersion) to $($updated.InstalledVersion)."
Write-Output 'Restart Codex, start a new task, and review the hook trust prompt if the hook changed.'
