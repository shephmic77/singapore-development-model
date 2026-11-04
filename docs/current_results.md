# Current research results

Updated: 2026-11-04

## What is now available
- World Bank data: 18 indicators, with coverage evaluated separately by year and indicator.
- V-Dem v16: 174 audited countries/economies and 10,008 country-year records. All 11 selected cases are included.
- Happiness: 164 matched countries/economies across 14 published reporting periods. All 11 cases have observations somewhere in the file.
- 19 exploratory model specifications, including openness, income-control and outcome-basket sensitivity.

## One descriptive finding
Singapore has a published life-evaluation score of 6.585 for 2023-2025. The matched international reference mean for that period is 5.643. This does not support assuming Singapore must have below-average happiness.
The score is a survey-based multi-year life evaluation, not an annual happiness reading or a causal policy effect.

## What the five areas mean now
### Economic performance
Two-indicator provisional score; growth as separate model outcome
Current analysis: Exploratory growth models include democracy, trade, effectiveness and controls
Still unresolved: Ownership/direct control and public investment now have separate specifications; broader industrial policy still incomplete

### Living standards
Four-indicator provisional score; fixed three-indicator sensitivity
Current analysis: Expanded association models and basket/control/openness sensitivity
Still unresolved: Health overlap and changing education coverage

### Happiness and well-being
Observed multi-year life-evaluation scores and provider uncertainty; not annual data
Current analysis: Models use non-overlapping survey windows and predictors before each window
Still unresolved: Annual Gallup series unavailable in the verified public download; one primary measure, not a composite

### Freedom and governance
Three-index provisional descriptive score from V-Dem; all three required
Current analysis: Democracy omitted from freedom-outcome model because components overlap
Still unresolved: Not an independent test of democracy effects; expert-coded uncertainty

### Social and distributional outcomes
Observed PIP survey measures; SWIID standardized income summaries; UNDP gender inequality; separate local case studies
Current analysis: Observed-survey within-block and UNDP gender models available; SWIID draw-based regression withheld by format audit
Still unresolved: Provider-modeled summaries are not direct surveys; GII overlaps other domains; no universal social composite

## Why the regression results remain provisional
Broad state intervention is still unmeasured. A separate IMF general-government investment extension tests one narrower fiscal activity. Trade share measures realized flows and country structure, not policy openness alone.
Democracy and freedom indices overlap conceptually. Democracy is therefore omitted from the freedom-outcome regression.
Country and year effects, lagging and clustered standard errors do not remove all confounding, reverse causality, source error or sample selection.
Happiness models use separate three-year windows and predictors from before each window. Annual Gallup data is not claimed.
The separate social-survey extension models income and consumption within provider comparability spells. Unrestricted pooling across survey concepts is not used, and no social composite has been manufactured.

## How to inspect results
Open outputs/START_HERE.html for the main guide. Use data/readable and outputs/readable_tables for labeled CSV files.
The model selections table shows missing-data sample loss. The VIF table shows collinearity after removing model fixed effects.
Development-stage matching is exploratory and may be left-censored by the beginning of observed PPP data. Matching cannot establish transferability.

## Next decisions
1. Decide whether the narrower economic-growth models and provisional baskets answer the intended question.
2. Review freedom measurement, social survey definitions and the absence of a defensible intervention measure.
3. Review the historical-income, regional and balanced-reference sensitivity; add stronger case evidence before transferability claims.

## Historical peers and coverage sensitivity
The official World Bank income-classification history is now integrated. A classification is assigned to the calendar year in which it is in force on July 1, not to the earlier GNI data year.
Raw peer means distinguish historical income groups from current geographic-region definitions. A balanced 2000-2024 reference keeps the same observed economies for each indicator; that selection is not automatically representative.
The current-high-income-membership sensitivity is retained and remains a different benchmark. No small-group peer z-score is represented as a global score.
