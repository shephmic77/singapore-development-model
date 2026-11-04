# Work log

## November 4, 2026: foundation

Built the R World Bank pipeline, metadata, country-year datasets, coverage reports, annual benchmarks, provisional scores and reduced models. A timed-out education download was retried successfully. The archived GE.EST code was replaced with the official current GOV_WGI_GE.EST code. The raw responses were preserved.

## November 4, 2026: readability

Added labeled dataset copies, clearer chart titles and axes, full country names, source notes, a column dictionary and a browser results guide. Numeric values were checked against the original output files.

## November 4, 2026: expanded sources and analysis

Added official V-Dem v16 R data and codebook at a recorded repository commit. Added the official World Happiness Report 2026 aggregate workbook. Kept original files, checksums, terms and country crosswalks.

The identity audit excluded V-Dem's West Bank from the combined World Bank West Bank and Gaza join. Distinct historical units and unmatched territories were not silently merged. Hong Kong and all 11 selected cases were retained.

Happiness was kept as multi-year reporting periods. The early period's start was not guessed. Models use non-overlapping windows and predictors from before the entire window. A descriptive freedom basket was added, but democracy was excluded from its outcome regression because the constructs overlap.

Expanded models compare income controls, trade versus tariffs, fixed living-standard baskets and the exclusion of Singapore/Hong Kong. Sample losses, country-clustered intervals, VIFs and diagnostics are exported. Calendar and exploratory stage comparisons are documented. A state-intervention measure and pooled social-outcome regression were not fabricated to complete the design.

The current methods, source guide, professor summary and research plan were updated. run_all.R provides one complete entry point. Exact validation outcomes are recorded in outputs/validation.txt and outputs/extended_validation.txt; these files, rather than this log, are the check record.

The source-preservation test also found Windows native-text substitution in two accented happiness provider names. A project-level UTF-8 text initializer was added, and cleaned exports were regenerated from the unchanged original workbook. This correction concerns text encoding; the numerical values were not manually changed.

## November 4, 2026: peer reference update

Added the official World Bank historical income-classification workbook. Kept fiscal year, GNI data year and the July 1 calendar assignment separate. Excluded unknown groups and starred retrospective combined-Yemen classifications. Added historical-income and current-region raw benchmarks, Singapore differences, a balanced 2000-2024 reference and a legible peer-comparison plot. These remain distinct from the earlier current-income-membership sensitivity. Peer timing, balanced sample counts and source checksums are validated.

## November 4, 2026: state-intervention and social-outcome extension

Collected the official IMF May 2021 investment workbook, OECD ownership-regulation assessments, a pinned September 2026 PIP survey release and two official Singapore Gini tables. Kept original downloads, versions, country IDs, exact definitions, source notes and checksums.

Defined the IMF ratio using same-source nominal investment and GDP. It is explicitly a measure of general-government capital formation, not total intervention. The vintage ends in 2019. OECD wave labels were not treated as common dates: actual legal-reference dates include later years, and no annual filling was applied.

Separated income/consumption welfare concepts and national/urban coverage in PIP. Social regressions use provider comparability blocks with at least three usable survey years. Paired investment models use identical observations with and without the term. All new model designs, sample gates and limits are documented.

Added separate Singapore employment/market-income definitions. Verified six Hong Kong census values visually against the rendered source table and retained the curated transcription and page reference. Neither case study fills missing PIP cells or creates a universal social score.

Created a topic report, six new figures, a measure catalog, a source-use audit and checks against provider values and exact model membership. The distribution-share check initially detected only vector-name attributes; the numerical differences were below floating-point rounding precision. The final source-value check compares numeric values without those unrelated row-name attributes. Validation outcomes are recorded in outputs/intervention_social_validation.txt.

## 2026-11-04: Better intervention and social measures
Added V-Dem ownership/control, SWIID 9.92 published standardized income summaries, and UNDP HDR2025 gender inequality. Preserved definitions, uncertainty, source hashes, coverage, and crosswalks. Kept PIP surveys separate from modeled summaries. Withheld SWIID regressions because draw-format checks remain unresolved; did not alter provider draws. Added 15 exploratory specifications, five charts, readable exports, methods/source guides, and source/sample validation. WIID download access remained unavailable; Fraser ownership was not treated as independent V-Dem evidence.

## 2026-11-04 Repository organization and supplied course materials
Added folder guides, source/reuse notes, a lightweight repository check, and a guarded GitHub sync command. Preserved existing R paths. Copied eight supplied course files under descriptive filenames with SHA256 verification and a manifest. Connected proposed hypotheses, five-category methods, earlier Vietnam case notes, current Zambia case membership, and source-inventory distinctions to the implemented analysis. Kept the Pokemon exercise separate. Original document contents, internal titles, and citations were not edited or newly verified.
