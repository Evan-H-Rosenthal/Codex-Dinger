# Codex Dinger

Codex Dinger plays a small sound when your **main Codex task** finishes. It uses Codex's `Stop` hook, so subagents, forks, primers, and intermediate activity do not produce false chimes.

Windows and PowerShell 5.1 are currently supported. The plugin has no network access, credentials, or telemetry.

## Install

```powershell
codex plugin marketplace add Evan-H-Rosenthal/Codex-Dinger
codex plugin add codex-dinger@codex-dinger
```

Restart Codex and trust the plugin's `Stop` hook when prompted. Finish any task to hear the bundled default chime.

## Use your own sound

Ask Codex naturally:

- "Add the attached sound to my Codex Dinger sound bank."
- "List my Codex Dinger sounds."
- "Use `my-chime.mp3` for Codex Dinger."
- "Set Codex Dinger volume to 40 percent."
- "Disable Codex Dinger."

Custom `.wav`, `.mp3`, `.wma`, and `.m4a` files up to 25 MB are copied to `%LOCALAPPDATA%\CodexDinger\sounds`. Preferences live in `%LOCALAPPDATA%\CodexDinger\settings.json`, so upgrades do not erase them.

## Update or uninstall

```powershell
codex plugin marketplace upgrade codex-dinger
codex plugin add codex-dinger@codex-dinger
```

```powershell
codex plugin remove codex-dinger@codex-dinger
codex plugin marketplace remove codex-dinger
```

Uninstalling does not delete the local sound bank. Remove `%LOCALAPPDATA%\CodexDinger` manually if you also want to erase preferences and custom sounds.

## How it works

The synchronous hook reads the event, starts a hidden playback worker, returns `{"continue":true}`, and exits. The hook never changes `notify` in Codex's `config.toml`, so existing Windows toast notifications remain intact.

Diagnostic logs are written under the plugin's Codex-managed data directory when available. Playback falls back to the bundled chime if the selected custom sound is missing.

## Audio licensing

The bundled `default-chime.wav` was created for Codex Dinger by the project author and is released under the MIT license with the code. Do not open a pull request containing downloaded audio unless its license explicitly permits redistribution.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for validation commands and [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) for release gates.

## License

MIT
