> Historical foundation document. Read docs/current_methods.md and docs/current_results.md for the expanded current study.

# Methodology

## Cleaning and provenance

Keep downloaded JSON unchanged. Save source indicator metadata separately. Remove World Bank regional, income and other aggregates using the country metadata aggregate marker. Join observations to country codes, require one observation per economy-year-indicator and preserve nulls as NA. No interpolation, forward filling, zero imputation or mixed latest-year comparisons. The wide CSV has one row per economy-year; the long CSV preserves indicator provenance. Exact API definitions take precedence over short catalog labels, especially PPP base years and poverty thresholds.

The current country catalog is not a historical territorial crosswalk. Years before a state's existence and discontinuous series require inspection before historical interpretation. The API may provide historical estimates for currently reported economies. Current income groups are metadata only, not historical controls.

## Reference statistics

Every available nonaggregate World Bank economy is eligible, including separately reported territories. This may exceed the desired 100 to 180 range; observations are not discarded simply to reach a target. Raw annual mean and sample standard deviation use available observations. Normalization uses transformed observations and at least 100 valid reference values. Undefined or zero standard deviations suppress z-scores. Report both raw and transformed sample counts.

For beneficial indicators, z = (transformed value - annual transformed mean) / sample SD. Reverse the sign for adverse indicators. Positive-only logs apply to income, productivity, infant mortality and population. Nonpositive values are missing for those transforms. Inflation has no unconditional monotonic desirability, so no welfare z-score is created. The percentile uses average ranks and midrank positions from 0 to 100, with direction reversed for adverse indicators. No overall country ranking is created.

The reference changes with missingness. Compare raw trends alongside z-scores. Fixed-2010 benchmarks and current-high-income-membership raw means are implemented in scripts/03_sensitivity.R. Common-country, historical income-group and regional benchmarks remain future sensitivity analyses. A high-income series built with current membership would answer a different question from historical peer performance.

## Category baskets

Economic pilot: logged PPP GDP per capita and reversed unemployment, both required. Growth, inflation and productivity remain separate. The basket weights income and employment equally; this is a transparent starting choice, not a validated economic welfare index.

Living pilot: life expectancy, reversed logged infant mortality, secondary attainment and electricity access. At least three of four are required. An available-indicator arithmetic mean gives equal weights among observed components. The basket signature and contributing count are exported because compositions can differ across observations. Missingness therefore affects comparability. Complete-basket leave-one-out results are exported. Life expectancy and mortality overlap; dropping either and using complete baskets should be reviewed before finalizing the score.

Happiness and freedom require additional sources. Social indicators are reported individually until income/consumption survey differences, gender-measure interpretation and coverage are reviewed. No scores are manufactured for those categories.

## Statistical pilot

Only the living basket receives reduced models in the first version, because the proposed four explanatory constructs are not all measured. A pooled model has year effects; a second has country and year effects. Predictors are trade share, WGI effectiveness, log income and log population, lagged by exactly one calendar year. A missing preceding year remains missing. Complete-case filtering starts at year 2000. At least 100 rows and 30 economies are required. Report country-clustered HC1 standard errors and t-based 95 percent intervals using cluster count minus one degrees of freedom.

Model output includes coefficients, sample sizes, economy counts, R-squared, design-matrix condition number, Breusch-Pagan check, maximum Cook's distance and within-country predictor standard deviations. Correlations report pairwise sample counts. A large condition number can partly reflect scaling and many fixed effects; it is not itself a variable-specific collinearity diagnosis. These checks are preliminary. Remaining diagnostics include explicit VIF/residualized predictor checks, residual plots, extreme-value review, sample-selection comparisons, cross-country dependence and alternative specifications.

Slow-moving political variables may have little useful within-country variation. Country effects do not identify their time-invariant component. Lagging does not remove reverse causality. No causal or policy-transfer claim follows from these models. GDP as a control may block a pathway of interest; models with and without it are needed later.

## Historical comparison design

Calendar comparisons hold the year constant but compare different development stages. Development-stage comparisons could identify the first sustained crossing of a PPP income band and compare outcomes within a prespecified window. They can create selection, cohort, survivorship and measurement problems. Use consistent PPP vintages, specify tolerance and sustained crossing in advance, and avoid matching on an outcome affected by the institution being studied without explaining that bias. Neither stage matching nor calendar comparison alone identifies policy effects. Stage matching is documented here but not implemented.


