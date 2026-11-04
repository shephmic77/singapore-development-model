# Better measures: methods in plain language

## 1. What improved and what did not

The project now has a more direct ownership/control indicator, standardized income-inequality summaries and a separate gender-inequality measure. Each answers a narrower question than total development or the full Singapore model. More coverage and a common definition do not guarantee that every number is directly observed or equally reliable.

## 2. State ownership and direct control

The V-Dem variable v2clstown asks about state ownership or direct control of important economic sectors. The response guide ranges from virtually all valuable capital under state control to very little. This is closer to ownership/control than government spending, but it is still an expert assessment rather than an administrative share of assets or firms.

V-Dem supplies both a latent measurement scale and an expected score on the original response scale. The project uses:

`Ownership/control index = 4 - v2clstown_osp`

Higher values on the resulting 0-4 index mean more ownership/control. They do not mean better development. A value of 2 is not 50 percent state ownership. Provider uncertainty bounds are reversed correctly: the transformed lower bound is 4 minus the original upper bound. They are not relabeled as 95 percent regression confidence intervals.

A sensitivity specification uses minus the original latent score. Its coefficient units differ from the 0-4 scale and must not be compared as identical magnitudes. Repeated yearly values and slow changes can limit within-country identification. The variation table reports actual distinct provider values and observed changes.

The existing audited V-Dem country crosswalk is reused. Hong Kong remains a separately reported economy. Earlier territorial exclusions remain in place. V-Dem's democracy and ownership measures share a provider, so common measurement judgments may influence their association.

The Fraser state-ownership component reviewed here is itself based on V-Dem. It is not counted as an independent ownership dataset or a separate confirmation. Ownership, public investment, directed credit and industrial policy remain distinct facets. No complete state-intervention index is declared.

## 3. More consistent income-inequality concepts

SWIID 9.92 published summaries target square-root-equivalized household income using Luxembourg Income Study data as the standard. Disposable income is after taxes and transfers; market income is before them. Both are reported on the 0-100 Gini scale. These are standardized/model-based provider estimates, not additional direct household surveys collected by this project.

The project preserves the published means, standard errors and provider-defined availability of redistribution measures. It does not calculate new redistribution values in missing cells or describe accounting differences as experimentally identified policy effects.

For descriptive charts, approximate provider uncertainty bands are calculated as the mean plus/minus 1.96 times the published standard error, following the provider's graphing guidance. They represent uncertainty in the provider estimate, not clustered regression uncertainty. The published means are not presented as exact measurements or used to produce a single overall development ranking.

All 11 selected cases have summary data, but their last years differ. Ghana ends in 2016 in this release. The latest common year for all 11 is therefore 2016. The comparison chart uses that same year for every case. Country-specific later values remain in the dataset but are never substituted into that common-year chart. Historical entities and unresolved territories are not automatically assigned modern codes.

## 4. Why SWIID regression is withheld

The provider's R and Stata files were inspected against the same archive's published summary. The R draws are not on the published 0-100 scale. A diagnostic division by 100 still does not reproduce all published summaries. The Stata draws are on a plausible Gini scale but also show unresolved summary discrepancies. The archive checksum matches Harvard Dataverse metadata.

Country-year keys were matched explicitly, rather than assuming the summary and draws have the same row order. The Stata country labels were read with explicit UTF-8 handling. The remaining discrepancies were not silently normalized away. A simple trial conversion is retained only in the diagnostic table, never as an accepted outcome series.

These findings establish that the draw formats have not passed this project's concordance gate. They are not a declaration that the provider is wrong; documentation, implementation details or release differences may require clarification. No synthetic replacement draws are generated. No SWIID regression is run on point estimates while claiming to have propagated the provider uncertainty. The published summary is a separate descriptive source, as recommended by the provider for graphs.

## 5. Gender inequality is a separate dimension

The UNDP Gender Inequality Index combines reproductive health, empowerment and labor-market dimensions. Lower values on its 0-1 scale mean less measured gender disadvantage. It is not a wage-gap percentage and not a complete social-outcome score.

The pipeline reads only gii_YEAR columns, excludes the rank column and removes regional/group aggregates by country identifiers. All values come from the same HDR 2025 vintage, covering 1990-2023. The source CSV's Latin-1 country-name encoding is explicitly decoded before UTF-8 export. Hong Kong's missing values remain missing.

A separate same-year relative score reverses the GII direction after standardization against at least 100 observed reference economies. It is not combined with income inequality or used to fill a universal social category. Health/education/participation overlap with existing dimensions is documented to avoid counting related information multiple times.

## 6. New regression specifications

Annual outcomes are real GDP per capita growth, the provisional living-standard basket and raw GII. The analysis window is 2000-2024 where source coverage permits; GII itself ends in 2023. Predictors come from exactly the previous year.

The ownership specification contains democracy, trade, government effectiveness and state ownership/control, with income and population controls and country/year effects. A baseline omits ownership on the identical complete-case sample. A latent-scale sensitivity checks the scale choice. Two additional specifications include both ownership and public investment on the shorter window through 2019.

Observed PIP survey models also test ownership. Income and consumption remain separate, national labels are required, provider comparability blocks are retained, and each block needs three usable survey years. These are not SWIID regressions.

Models need at least 100 observations and 30 economies. They report country-clustered standard errors and t-based 95 percent intervals. Sample membership, VIFs after removing fixed effects and remaining predictor variation are exported. Predictor measurement uncertainty is not propagated, so the intervals are conditional on the point indicators. Lagging, fixed effects and clustering do not establish causality or policy transferability.

## 7. What still needs work

Ownership/control is not the whole development model. Independent ownership validation, directed-credit and industrial-policy measurement, stronger historical case evidence and source-measurement uncertainty remain open. More consistent inequality definitions depend on standardization assumptions, and the SWIID draw compatibility issue must be resolved before uncertainty-aware regression. No universal social composite is forced.
