# Source guide

## Sources used now

| Source | Version and access | Terms and attribution | Important limits |
| --- | --- | --- | --- |
| World Bank WDI / WGI | API v2; raw JSON and source-update dates retained | Cite World Bank and original providers listed in metadata. World Bank default is CC BY 4.0 with additional terms; check third-party exceptions. | Reporting and survey concepts differ; missing values remain missing. |
| V-Dem | Country-Year v16, official vdemdata R files at a pinned repository commit | CC BY-SA 4.0. Cite Coppedge et al. (2026), V-Dem Country-Year Dataset v16, DOI 10.23696/vdemds26. Retain share-alike terms for derivatives. | Expert-coded estimates, provider uncertainty and overlapping index components; do not splice vintages. |
| World Happiness Report | 2026 Figure 2.1 workbook | Public aggregate download. Cite Helliwell et al. (eds.), World Happiness Report 2026, University of Oxford Wellbeing Research Centre, and Gallup. No microdata rights are assumed. | Published multi-year life-evaluation averages; not an annual Gallup series. |

Original files remain in data/raw. World Bank request records are in data/raw/manifest.csv. Additional provider URLs, file times, versions and checksums are in metadata/additional_source_manifest.csv. File modification times are explicitly identified as the source of the added download timestamps. New downloads record their own local file time. Raw files are not overwritten.

## Indicator and identity documentation

- metadata/indicators.csv: original 18 indicators, short definitions, units, directions and limits.
- metadata/source_definitions.csv: exact World Bank descriptions and underlying providers.
- metadata/additional_indicators.csv and additional_source_definitions.csv: V-Dem catalog and definitions.
- metadata/vdem_selected_definitions.csv: original codebook fields for the selected indices.
- metadata/vdem_country_crosswalk.csv: reviewed matches and exclusions, including territorial scope.
- metadata/happiness_country_crosswalk.csv: provider names, explicit aliases and unmatched units.
- metadata/output_catalog.csv: dataset purposes and row counts.
- metadata/output_column_dictionary.csv: technical-to-readable column mapping.

## Official links

- World Bank API: https://datahelpdesk.worldbank.org/knowledgebase/articles/889392
- World Bank licensing: https://datacatalog.worldbank.org/public-licenses
- WGI: https://www.worldbank.org/en/publication/worldwide-governance-indicators
- WGI revised methods: https://www.worldbank.org/content/dam/sites/govindicators/doc/The%20Worldwide%20Governance%20Indicators%202025%20Methodology%20Revision.pdf
- V-Dem data, terms and citation: https://www.v-dem.net/data/the-v-dem-dataset/
- Official R repository: https://github.com/vdeminstitute/vdemdata
- Happiness download and citation: https://www.worldhappiness.report/data-sharing/
- Happiness interpretation: https://www.worldhappiness.report/faq/

The current WGI API code is GOV_WGI_GE.EST. The old GE.EST returned archived metadata without observations. Those original responses are retained as an audit trail. The new estimate series is not spliced with the separate 0-100 governance score.

## Candidates reviewed but not used as intervention measures

- OECD PMR: https://www.oecd.org/en/topics/product-market-regulation.html . Useful regulatory/public-ownership components, but periodic data and selected jurisdictions do not automatically support the intended annual international panel.
- IMF NIPO/GTA: https://www.imf.org/-/media/files/publications/wp/2024/english/wpiea2024001-print-pdf.pdf . Recorded industrial-policy interventions need a concept, coverage and monitoring-intensity audit before being treated as state intervention.
- Updated NIPO context: https://www.imf.org/en/blogs/articles/2026/05/28/industrial-policy-is-adapting-to-crises-but-remains-hard-to-implement-effectively . Do not assume the initial release's coverage applies to newer releases.
- ILO working hours: https://ilostat.ilo.org/methods/concepts-and-definitions/description-wages-and-working-time-statistics/ . Definitions and employment coverage require harmonization.
- UNDP: https://hdr.undp.org/data-center . HDI may provide external descriptive validation; adding HDI alongside its own income, health and education components would double count dimensions.

Housing affordability, social mobility and mental health remain deferred instead of being filled with unrelated proxies. Poverty is assigned to social outcomes rather than counted in two categories. Market openness is not synonymous with realized trade share. Government spending is not synonymous with industrial policy.

## Historical income classifications now used

Official explanation and download: https://datahelpdesk.worldbank.org/knowledgebase/articles/378834-how-does-the-world-bank-classify-countries . Download URL: https://ddh-openapi.worldbank.org/resources/DR0095334/download . The raw workbook, file time and checksum are preserved separately in metadata/historical_classification_manifest.csv. The country-history sheet's own fiscal and GNI-year labels are used; an older Parameters sheet is not treated as the dataset vintage. The July 1 calendar-assignment convention and starred historical exclusions are documented in current_methods.md.
