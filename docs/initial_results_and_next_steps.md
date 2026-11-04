> Historical foundation document. Read docs/current_methods.md and docs/current_results.md for the expanded current study.

# Initial results and next decisions

## Verified run: November 4, 2026

- R pipeline executed successfully.
- All 18 cataloged indicators have observations somewhere in the retrieved panel.
- 133,277 nonmissing indicator values were retrieved.
- The reference catalog has 217 countries and separately reported economies.
- All 11 selected cases are included. This does not mean every indicator is available for every case and year.
- Two provisional category baskets were produced. Happiness, freedom and social composites remain withheld.
- Both reduced living-standard models used 3,703 country-year observations from 177 economies.
- Output validation passed. See outputs/validation.txt for the checks performed.
- The final collection failure table is empty. Original failed WGI response and archived metadata remain in raw data as an audit trail.

## Preliminary findings

Singapore's World Bank life-expectancy series rises from 67.23 years in 1965 to 83.35 in 2024. This is a descriptive change and does not identify its cause.

The pooled model with year effects estimates a positive government-effectiveness association with the living basket: 0.117 score units per estimate unit, with a country-clustered 95 percent interval of 0.007 to 0.227. With country and year effects, the estimate is 0.021 and the interval is -0.026 to 0.068. This sensitivity illustrates why pooled cross-country associations should not be interpreted as institutional effects. Trade-share intervals include zero in both specifications. These are reduced models with omitted constructs and a changing outcome basket.

The models show strong evidence of heteroskedasticity in the preliminary diagnostic. Country-clustered inference is used. Large design-matrix condition numbers also call for further collinearity and scaling review. These results are exploratory, not final paper findings.

## Important gaps

Education averages about 83 observed economies per year in 2000-2025. Gini and poverty each average about 72. The annual 100-economy normalization gate suppresses scores when coverage falls below the requirement. Observations are not interpolated to force coverage.

Annual happiness and V-Dem data are not yet integrated. A comparable state-intervention variable has not been approved or substituted. Government consumption remains a contextual measure only. No full five-outcome/four-explanatory-variable analysis is claimed.

## Decisions for the next phase

1. Review the economic and living baskets, especially overlapping health indicators and changing composition.
2. Obtain an appropriate annual happiness series and confirm V-Dem coverage and identifiers.
3. Decide whether industrial-policy or ownership data can support the intervention question, or use an explicitly reduced model.
4. Set the main analysis period after reviewing coverage. Keep the longer historical case study separate.
5. Define historical peers and stage-matching rules before testing them.
6. Review missingness, influence, alternative controls and consistent-basket samples before interpreting model coefficients.

The project is a working initial research foundation. The full study remains incomplete for the explicit data and measurement reasons above.

