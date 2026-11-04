# Data guide

| Folder | Use |
| --- | --- |
| [readable/](readable/) | Start here: clear headings, country names, and units |
| [clean/](clean/) | Stable technical columns used by the R scripts |
| raw/ | Original local downloads, excluded from GitHub |

Readable and technical copies preserve the same numeric values. They are views of the same data, not independent evidence. The [catalog](../metadata/output_catalog.csv) explains files; the [dictionary](../metadata/output_column_dictionary.csv) connects column names.

Blank cells represent missing values. Coverage, welfare concepts, years, and source types vary. PIP surveys, SWIID modeled summaries, UNDP composites, and V-Dem expert assessments remain separate.

Run `source("run_all.R")` from the root to retrieve sources and reproduce outputs. Raw files are immutable local caches. Preserve them before deliberately refreshing a source vintage. Provider access, attribution, and reuse terms still apply: see [source notes](../SOURCE_NOTES.md).
