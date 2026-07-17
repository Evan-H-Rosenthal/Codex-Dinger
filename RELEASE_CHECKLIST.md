# Release checklist

## Every release

- [ ] Confirm every bundled asset has a redistributable license or was created in-repo.
- [ ] Update the strict semantic version in `plugin.json` and add changelog notes.
- [ ] Run `powershell -File tests/run-tests.ps1` on Windows PowerShell 5.1.
- [ ] Run the plugin and skill validators documented in `CONTRIBUTING.md`.
- [ ] Test main-task completion while Codex is focused and unfocused.
- [ ] Test a task that uses a subagent and confirm only the main `Stop` hook chimes.
- [ ] Test add, list, select, preview, volume, disable, enable, and remove.
- [ ] Install from a clean checkout using the README commands.
- [ ] Tag the commit as `vX.Y.Z` and publish release notes.

## Before 1.0

- [x] Add CI validation on Windows.
- [ ] Add a signed release or documented checksum workflow.
- [ ] Recruit testers on supported Codex Desktop and CLI versions.
- [ ] Document compatibility changes if the hook contract changes.
