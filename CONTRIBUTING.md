# Contributing

Pull requests are welcome. Keep the Stop hook fast and best-effort: playback errors must never block Codex from completing a task.

## Validate

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1
python "$env:USERPROFILE\.codex\skills\.system\plugin-creator\scripts\validate_plugin.py" .\plugins\codex-dinger
python "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .\plugins\codex-dinger\skills\manage-dinger-sounds
```

Only commit audio that you created or have an explicit license to redistribute. Include its source and license in the pull request.
