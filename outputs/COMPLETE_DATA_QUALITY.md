# Data quality across all sources

## World Bank
See outputs/data_quality_report.md for indicator-by-indicator missingness. The modern summary covers 2000-2025; annual models end in 2024. Education, poverty and inequality have substantial gaps.

## V-Dem
The country crosswalk retains 174 matched units. Annual coverage and normalization eligibility are exported separately by index and year. Historical raw values are not assumed territorially equivalent across time.
Provider uncertainty bounds and standard deviations are preserved. Point-score regressions do not propagate the full provider measurement uncertainty.

## Happiness
The dataset includes 164 matched economies across 14 published reporting periods; individual periods cover fewer. The latest period has the observed count recorded in happiness_period_scores.csv.
Multi-year averages are not independent annual observations. Model windows do not overlap. Missing early-period confidence bounds remain missing, and the early period start is not inferred.
Original accented provider names are preserved using a tested Windows UTF-8 text setting. Values are checked against the original workbook.

## Peer references
Income-group membership uses the July 1 classification in force during the observation year. Unknown and retrospective starred classifications are not assigned a usable group.
Regional membership is the current World Bank region definition. Balanced samples retain only economies observed in every year 2000-2024 for the relevant indicator, which changes the target population.

## Reading sample sizes
A reference count describes economies with observed values, not people surveyed. Regression observations are country-year rows or happiness windows. Model selection tables record losses from missing predictors.
See additional_source_coverage.csv, coverage_by_year.csv, case_missingness.csv and expanded_model_selections.csv. The two validation text files record actual checks; a passing check is not a guarantee of source accuracy or causal validity.

## Latest fiscal/social extension
See INTERVENTION_SOCIAL_DATA_QUALITY.md and intervention_social_validation.txt for the newly added sources and checks.
