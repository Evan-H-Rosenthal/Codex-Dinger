---
name: manage-dinger-sounds
description: Manage Codex Dinger's local sound bank and preferences. Use when the user asks to add an attached audio file, list or preview sounds, choose the active sound, change volume, enable or disable the chime, remove a custom sound, or inspect Dinger status.
---

# Manage Dinger Sounds

Run `../../scripts/manage-sounds.ps1` from this skill directory with PowerShell. Prefer `-Action Status` before changing a setting when the current state matters.

## Commands

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/manage-sounds.ps1" -Action List
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/manage-sounds.ps1" -Action Add -Path "C:\path\sound.mp3"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/manage-sounds.ps1" -Action Select -Name "sound.mp3"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/manage-sounds.ps1" -Action Preview -Name "sound.mp3"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/manage-sounds.ps1" -Action Volume -Value 50
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/manage-sounds.ps1" -Action Enable
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/manage-sounds.ps1" -Action Disable
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "../../scripts/manage-sounds.ps1" -Action Remove -Name "sound.mp3"
```

Use `default` as the name to select or preview the bundled chime. Resolve an attached file to its real local path before adding it. The manager accepts `.wav`, `.mp3`, `.wma`, and `.m4a` files up to 25 MB.

Confirm before overwriting an existing bank entry or removing a sound. Pass `-Force` only after confirmation. Report the resulting active sound, enabled state, and volume.
