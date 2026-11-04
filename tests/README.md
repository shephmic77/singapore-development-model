# Validation

The complete `run_all.R` workflow runs four research-validation scripts after rebuilding outputs. They check completeness, source preservation, matching, timing, references, and samples. Some require raw caches, which are excluded from GitHub.

The lightweight `validate_repository.R` uses base R to check files, local report links, and R syntax without downloading sources or rerunning models:

```powershell
& 'C:\Program Files\R\R-4.5.1\bin\Rscript.exe' tests/validate_repository.R
```

Run this repository check locally when needed. It is distinct from a full source download and statistical reproduction.
