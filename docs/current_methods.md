Latest update: see outputs/BETTER_MEASURES.html and docs/better_measure_findings.md. State ownership/control is now measured separately from public investment. SWIID standardized summaries improve income-concept comparability but remain descriptive while draw-file checks are unresolved. UNDP gender inequality is a separate outcome; Hong Kong is missing. See docs/better_measure_methods.md and docs/better_measure_sources.md for definitions and limits.

# Methods: the current version

## 1. Research question

The project asks how Singapore performs across five development areas, how it compares with other economies, and which institutions are associated with outcomes. An association is a statistical pattern. It does not establish that an institution caused the outcome or that another country can reproduce Singapore's experience.

## 2. Data now used

| Source | What it adds | How time is handled |
| --- | --- | --- |
| World Bank WDI and WGI | Economic, living-standard and social indicators; trade and government effectiveness | Observed country-year values; no filling missing years |
| V-Dem Country-Year v16 | Electoral democracy, liberal democracy, civil liberties, expression and association | Raw history from 1965 where available; modern benchmarks start in 2000 |
| World Happiness Report 2026 / Gallup | Life evaluation on a 0-10 ladder and published confidence bounds | Multi-year reporting periods; never relabeled as annual survey data |

All 11 selected cases are retained. Hong Kong is a separately reported economy. Provider crosswalks record exact matches, explicit aliases and exclusions. V-Dem's West Bank series is excluded from the World Bank join because the latter reports West Bank and Gaza together. Distinct historical states and unmatched territories are not silently merged into present-day countries.

The World Bank has 217 nonaggregate reference economies. The matched V-Dem reference has fewer because coverage and reporting units differ. Happiness has its own available-period reference. Counts accompany the benchmarks. Modern matching does not certify historical territorial continuity; pre-2000 V-Dem data are retained for descriptive inspection rather than automatically used for international standardized comparisons.

## 3. Measurements and category scores

Economic performance uses a provisional mean of logged PPP income and reversed unemployment scores. Real GDP per capita growth is modeled separately and is clearly labeled as a different outcome.

Living standards use life expectancy, reversed logged infant mortality, secondary attainment and electricity access. At least three of four scores are required. A separate fixed basket requires all three health/electricity components to check changing education coverage. The fixed basket still includes two related health measures; it is a sensitivity analysis, not a final validated index.

Freedom has a provisional descriptive mean of three V-Dem indices: civil liberties, expression/alternative information and association. All three are required. These measures overlap with democracy concepts. Democracy is therefore omitted from the freedom-outcome regression. This basket describes a rights dimension and is not a separate independent validation of democracy effects.

Happiness uses the reported life-evaluation score itself. It is one primary measure, not a multi-indicator category composite. The source's explanatory contribution bars are not additional observed happiness outcomes. Scores and ranks remain separate.

Social outcomes do not receive a forced composite. The later fiscal/social extension uses separate income and consumption models within provider comparability blocks. Local Singapore and Hong Kong definitions remain separate. See intervention_social_methods.md for those models.

Each annual indicator score uses its own available reference for that year, at least 100 economies, and the sample standard deviation. Higher normalized scores are better under the stated direction convention. A category score is the mean of eligible indicator z-scores; its own distribution is not rescaled to unit variance. No overall development rank is calculated.

## 4. Expanded regression design

The main annual window is 2000-2024. This avoids making partial 2025 outcome coverage the main comparison sample. Predictors are electoral democracy, trade share, government effectiveness, log PPP income and log population, measured in exactly the previous calendar year.

For economic growth and living standards, the analysis compares:

1. Year effects only.
2. Country and year effects.
3. Country and year effects without income as a control.
4. Applied tariffs replacing trade share.
5. Excluding Singapore and Hong Kong.

A fixed living-standard basket repeats these specifications. Country effects remove time-invariant differences; year effects remove shared calendar shocks. Slow-moving predictors may have little usable variation after these adjustments.

Happiness models use non-overlapping three-year windows anchored to the latest available window. Predictors are from the year before the entire window begins. These are window-level models, not annual models. An observed average may include surveys from only part of its nominal reporting window. The early provider period is retained with its start unassigned, and excluded from these models.

Models require at least 100 observations and 30 countries/economies. They use complete cases and country-clustered standard errors, with t-based 95 percent confidence intervals using the number of clusters minus one degrees of freedom. Sample-selection tables report how missing predictors reduce available outcomes. VIFs are calculated after removing the same fixed effects as the model. Diagnostics also report heteroskedasticity and influence summaries.

Income may be a mediator rather than a confounder; removing it changes the question. Tariffs are a partial policy measure with endogenous import weights. Trade is affected by geography and size. Excluding entrepot economies is a sensitivity check, not proof of a correct specification. Country clustering does not resolve cross-country dependence. No regression incorporates a valid state-intervention measure yet. No model is presented as causal.

## 5. Historical comparison

Calendar tables hold the requested year constant. Missing years are not replaced with another year's value.

The exploratory stage comparison uses Singapore's PPP GDP per capita in 2000 as a clearly identified benchmark. It finds the first observed qualifying year with income between 100 and 110 percent of that benchmark, followed by two further observed years at or above the benchmark. A country can have no qualifying window. An observation at the beginning of its available series is marked left-censored: the actual first crossing is unknown.

The sustained-crossing rule uses later information and selects countries by an outcome. It may introduce selection bias and cannot identify the effect of institutions. PPP vintages, cohort differences, historical events and other development dimensions also matter. This is a descriptive comparison design, not a claim of policy transferability.

## 6. What is still missing

A broad comparable state-intervention index remains unavailable. A separate extension now tests IMF general-government investment as a narrower fiscal measure. Government consumption is not substituted for ownership or industrial policy. OECD PMR has useful public-ownership/regulatory measures but periodic coverage; NIPO/GTA records interventions rather than a universal annual state-intervention intensity. The later source audit retains OECD PMR as a dated descriptive supplement and keeps NIPO/GTA deferred. See intervention_social_sources.md.

Stronger historical case evidence, detailed social survey harmonization, residual visual diagnostics and cross-country-dependence sensitivity remain further work. Historical-income, regional and balanced references are implemented as described in section 7. The existing current-high-income means are labeled as using today's membership, not historical peer membership.

## 7. Historical and geographic peer benchmarks

The official World Bank historical analytical-classification workbook is now included. Its country-history sheet separates fiscal year from the GNI data year. FY2025 is in force from July 2024 through June 2025. The benchmark assigns that classification to calendar year 2024 using an explicit July 1 convention. This is not a claim that the classification applied for the full calendar year. The classification is based on Atlas GNI per capita, which differs from PPP GDP per capita. The observed classification series begins with the July 1988 assignment in the downloaded sheet.

Unknown classifications remain unassigned. Starred early-Yemen classifications are excluded because the workbook footnote describes a retrospective combined-country calculation. Source labels and fiscal/GNI years are retained.

Peer tables report raw means, standard deviations, group membership counts and observed counts. Historical income membership changes with the published classifications. Regional groups use today's geographic region definition, not a reconstructed historical region system. No peer z-score is presented as a global score.

A separate balanced reference uses only economies with observed values in every year 2000-2024 for each indicator. It fixes country composition within an indicator, but can remove less-documented economies and therefore change the population being described. The available-case global reference and current-high-income sensitivity remain separate. These reference comparisons are descriptive, not causal matching.


## Latest fiscal/social extension

The current extension documents the IMF investment ratio, dated OECD ownership assessments, pinned PIP survey concepts and separate Singapore/Hong Kong local sources. It adds narrowly labeled investment models and social models using provider comparability blocks. The main methods are in intervention_social_methods.md; source and rights notes are in intervention_social_sources.md. This extension does not make the broader state-intervention concept or a universal social composite complete.
