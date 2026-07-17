---
name: update-codex-dinger
description: Check for and install Codex Dinger updates from its configured GitHub marketplace. Use when the user asks whether Codex Dinger is current, wants to check for a new version, or says to update, upgrade, or reinstall Codex Dinger.
---

# Update Codex Dinger

Run `../../scripts/update-plugin.ps1` from this skill directory with Windows PowerShell.

For a check-only request, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/update-plugin.ps1" -Action Check
```

For an explicit update or upgrade request, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/update-plugin.ps1" -Action Update
```

Allow the updater's network and Codex configuration changes when approval is requested. Do not run `Update` for a check-only request. Report installed and available versions, then tell the user to restart Codex and review hook trust after a successful update.