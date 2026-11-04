# R workflow

Run `source("run_all.R")` from the root. The runner controls the order; some scripts call others.

| Stage | Scripts |
| --- | --- |
| Packages | 00_setup.R |
| World Bank foundation | 01_pipeline.R, 02_analysis.R |
| Sensitivity and foundational plots | 03_sensitivity.R, 04_model_plot.R |
| Institutions and happiness | 06_additional_sources.R, 07_expanded_analysis.R |
| Historical income, regional, balanced references | 09_peer_benchmarks.R |
| Investment and observed surveys | 10_intervention_social_sources.R, 11_intervention_social_analysis.R |
| Ownership, standardized inequality, gender | 13_better_measure_sources.R, 14_ownership_social_analysis.R |
| Labeled exports and reports | 05_reader_outputs.R, 08_current_report.R, 12_intervention_social_report.R, 15_better_measure_report.R |

Do not independently run every script in numeric order. `text_encoding.R` handles Windows text encoding. For report-only refreshes, run `source("scripts/05_reader_outputs.R")` after analysis files exist.
