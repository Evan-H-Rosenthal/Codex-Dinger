# Security policy

Please report security issues privately through [GitHub's security advisory form](https://github.com/Evan-H-Rosenthal/Codex-Dinger/security/advisories/new).

Codex Dinger runs local PowerShell scripts and reads local audio files. It does not require network access, credentials, or telemetry. Custom sounds are copied into `%LOCALAPPDATA%\CodexDinger\sounds` and are never executed.
