# Better state and social measures: current update

## What improved
State ownership/direct control is now measured separately from government investment. V-Dem asks about ownership/control of important sectors and covers all 11 cases through 2025. It is an expert assessment, not a count of state-owned firms or an asset percentage.
SWIID adds standardized disposable- and market-income inequality concepts using a common household equivalence scale. These are provider-modeled estimates with uncertainty, not newly observed survey records.
UNDP adds a standardized gender-inequality dimension through 2023. Hong Kong has no value in this release and remains missing.

## Coverage and fair comparisons
The latest year shared by all 11 SWIID cases is 2016 . The common-year chart uses that year for everyone.
Newer values are retained for countries where the provider supplies them. A missing country-year is not forward-filled or silently replaced with another year.

## New analysis
15 ownership model specifications were estimated. Annual models cover growth, living standards and gender inequality; observed-survey models retain separate welfare concepts and comparability blocks.
The ownership specification includes democracy, trade, government effectiveness and ownership/direct control, plus income/population controls and country/year effects. It measures one state-involvement facet, not every industrial-policy tool.
A matched baseline omits ownership; an alternative uses the reversed latent scale. Two joint specifications retain public investment in the shorter pre-2020 window.

## Important quality gate
The SWIID supplied draw formats did not pass the project's scale/summary-concordance audit. The R draws are not on the published Gini scale, and a diagnostic division by 100 does not resolve all summary discrepancies. Stata draws are on the Gini scale but also have unresolved discrepancies.
This is a documented unresolved compatibility issue, not an assertion that the provider is wrong. No guessed rescaling, new artificial draws or SWIID draw-based regression is used. Published summaries are used only for clearly labeled descriptive comparisons, as the provider recommends for graphing.
The corrected September 2026 WIID Companion was identified but its official download returned HTTP 403. No bypass or substitute copy was used.

## What remains unresolved
Expert ownership estimates do not measure directed credit, detailed industrial policy, implementation quality or all government-company activity. Their uncertainty and shared V-Dem measurement with democracy limit interpretation.
Standardization improves the consistency of income concepts by imposing modeling assumptions; it does not make every estimate a directly comparable observed national survey.
Gender inequality overlaps some health and education measures already used elsewhere. The project therefore keeps these dimensions separate and does not create a universal social composite or an overall country ranking.

## Read next
- outputs/BETTER_MEASURES.html: simple visual report.
- docs/better_measure_methods.md: definitions, choices and limits.
- docs/better_measure_sources.md: source versions, terms and candidate decisions.
- outputs/readable_tables/ownership_social_case_coverage.csv: all 11 cases and actual last years.
- outputs/readable_tables/swiid_draw_format_audit.csv: the unresolved format audit.
