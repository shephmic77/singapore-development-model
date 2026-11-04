# Keep the SODA folder and GitHub together

Repository: https://github.com/shephmic77/singapore-development-model

The working copy is `C:\Users\mikey\Desktop\PSU\SODA 308`. Edit the project there so RStudio, saved results, and Git refer to the same files.

## Sync reviewed changes

Open PowerShell in the SODA folder and run:

```powershell
powershell -NoProfile -File .\sync_github.ps1
```

This commits and pushes included files and verifies the remote commit. It does not rerun analyses or collect new observations. Use `source("run_all.R")` in RStudio to refresh analyses, review the results, then sync.

Raw downloads, installed packages, session history, credentials, and the original assignment/background request are excluded. The repository is public: included changes become visible to anyone. Provider-specific attribution and reuse terms still apply. Review new files before syncing.

The script stops on another branch, an unexpected remote, a Git failure, tracked local-only files, or upstream changes missing locally. It never force-pushes or overwrites divergent GitHub work. Resolve reported conflicts before trying again. Git for Windows needs authorized push access; its normal sign-in prompt may appear on first use.

## Checking synchronization

```powershell
git status --short
git log -1 --oneline
git ls-remote origin refs/heads/main
```

A clean status and matching local/remote commit mean the included snapshot is synced. Ignored local files remain only on this computer. There is no continuous filesystem watcher; any recurring sync schedule is separate from this command.