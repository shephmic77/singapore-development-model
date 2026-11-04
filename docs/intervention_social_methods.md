# State intervention and social outcomes: methods

## Read this first

There is no single measure here called total state intervention. The update adds a narrower measure of government investment and a separate audit of public-ownership regulation. Social outcomes are analyzed with their survey definitions attached. Missing coverage is never treated as a zero outcome.

## 1. What each source measures

| Source | Usable measure | What it does not establish |
| --- | --- | --- |
| IMF investment dataset, May 2021 | General-government investment in fixed assets as a share of GDP | Total public-sector ownership, directed credit or industrial-policy intensity |
| OECD PMR workbook | Regulatory distortions associated with public ownership | Government-owned share of GDP or a complete annual intervention series |
| World Bank PIP, September 2026 | Survey-based poverty, Gini and distribution shares, with coverage and welfare labels | Identical income concepts across every country or complete annual observations |
| Singapore official tables | Separate Gini definitions for employment/market income, household populations and tax treatments | A ready-made replacement for missing PIP observations |
| Hong Kong 2021 census report | Six verified Gini observations for two household populations in three census dates | An annual series or a directly harmonized Singapore/PIP comparison |

## 2. Public investment: a narrow explanatory variable

Government investment is general-government gross fixed capital formation. The variable is calculated as:

`100 x IMF nominal government investment / IMF nominal GDP`

The numerator and denominator come from the same country-year and the same dataset. They are not combined with a different PPP vintage from the World Bank. Original source variables and definitions are retained. An unavailable denominator, a nonpositive denominator or an invalid negative numerator does not produce a usable ratio.

The workbook's vintage is May 2021 and its data end in 2019. It covers all 11 cases, but the number of observed usable years differs. No values after 2019 are invented. General government is narrower than the whole public sector and can exclude public corporations. This is especially relevant when studying a development model involving government holding companies.

The new regressions use the previous year's investment share alongside democracy, trade, government effectiveness and selected controls. Main annual outcomes end in 2019. A separately labeled sensitivity includes the 2020 outcome using the 2019 predictor. Models with and without the investment term use exactly the same complete observations, so a coefficient change is not merely a change of sample. Removing income as a control is another sensitivity, on the main matched sample.

Higher investment is not automatically better. It can reflect development needs, a response to weak activity, spending quality or other policies. These regressions do not identify a causal return to investment, and do not measure all state intervention.

## 3. OECD ownership assessments

The ownership-distortion component is retained on the source's 0-6 scale. Higher means more restrictive/distortionary regulation under that framework. It is not the fraction of firms or output owned by government.

The workbook has 2018 and 2023-24 wave labels, but country-specific legal-reference dates differ. Some records in the newer wave refer to laws in 2025 or 2026. Some older-wave records also refer to dates later than 2018. The pipeline preserves actual dates and flags dates outside the main annual study window. It does not assign every record to the wave-name year, interpolate between waves or carry scores into missing years.

Singapore has no assessment in the downloaded waves. Selected cases and dates are shown explicitly in the coverage table. This source therefore remains a periodic descriptive supplement, not the missing universal annual predictor.

## 4. Social outcomes: keep the survey concept

PIP is pinned to release `20260922_2021_01_02_PROD`. Poverty uses USD 3 per person per day at 2021 purchasing-power-parity prices. This is a common international line, not a Singapore-specific or national relative-poverty standard.

Gini is converted from 0-1 to 0-100. Poverty headcounts and distribution shares are converted from fractions to percentages. Bottom-40 share is the sum of the first four decile shares. These are unit conversions, not new observations. Related inequality measures are not treated as independent ingredients of an arbitrary composite.

Income means resources received; consumption means goods and services used. A Gini calculated from income is not assumed equivalent to one calculated from consumption. The cleaned data retains both and the models estimate them separately.

The strict national subset requires all of the following:

1. The provider labels the reporting level as national.
2. The provider labels the survey coverage as national.
3. The record is a survey estimate and is not flagged as interpolated.

These provider labels are useful filters, not a guarantee that every survey covers every population group identically. Rural/urban and other non-national records remain visible in the full survey dataset. Argentina's records in this snapshot are urban-only and do not enter national models. Singapore and Hong Kong are absent from PIP in this snapshot; they are not assigned zero inequality or poverty.

## 5. Comparability blocks and social regression

The provider identifies breaks in comparability over time. A comparability identifier of zero is the first block, not a failed quality score. The pipeline defines a block using country, welfare type, coverage, provider comparability identifier and comparable-spell label.

Social models use fixed effects for these within-country blocks and reporting years. They retain blocks with at least three usable survey years after predictor filtering. Standard errors are clustered by country/economy. Each estimated model must have at least 100 rows and 30 economies. The same-sample models with and without investment are paired exactly.

The broad model without investment uses observed survey reporting years from 2000-2024. The paired investment models use reporting years through 2019 because of the IMF vintage. No missing survey years are filled. Predictors are joined to the preceding reporting year. Survey fieldwork/welfare reference periods can span more than one year, so this annual lag is only approximate temporal ordering and is not a causal identification design.

Outcomes are Gini and the USD 3 poverty rate, separately for income and consumption. A positive association means higher measured inequality or poverty, not a better outcome. These exploratory linear models allow flexible associations but do not constrain fitted values to the outcome bounds. Missing-data selection, measurement error and cross-country dependence remain concerns. The models do not propagate full source measurement uncertainty.

## 6. Singapore and Hong Kong remain separate case studies

Singapore employment-income tables describe resident employed households. Market-income tables describe resident households more broadly and include non-employment sources. The data retain per-member, modified-OECD and square-root equivalence scales, as well as before/after tax and transfer definitions. The main plot uses only the per-member scale in separate panels. It does not splice the populations or treat an accounting difference as a causal tax effect.

Hong Kong data are six manually transcribed values from the official census report, Table 6.1, printed page 98/PDF page 110. The rendered source was visually checked. Both series use per-person income after taxes and social benefits; the populations differ. The benefit concept includes in-kind services and one-off relief. No annual values are interpolated. The curated transcription, source page and checksum are retained.

These local series are not inserted into the international PIP panel. An apparent match in a Gini label or value is insufficient to establish a common welfare definition.

## 7. What can be concluded now?

The project can describe observed investment and social outcomes, compare alternative model specifications, and investigate within-comparability-block associations. It cannot rank all 11 cases using a fully comparable social composite, equate public investment with the whole Singapore model, or claim that the associations show transferable causal effects.

The investment vintage cannot evaluate policy changes after 2019. Modern case-study questions, including recent changes in El Salvador, need newer and appropriately defined evidence.
