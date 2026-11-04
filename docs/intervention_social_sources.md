# Source guide: state intervention and social outcomes

## Collected sources

| Provider | Exact source | Version / unit | Access and attribution |
| --- | --- | --- | --- |
| IMF | Investment and Capital Stock Dataset workbook | May 2021; original nominal/constant-2017-PPP variables retained; derived investment/GDP ratio in percent | Public official download; cite IMF and vintage. The general terms page could not be verified through the web tool, so no blanket redistribution license is claimed. |
| OECD | Economy-wide PMR indicator workbook | Downloaded November 2026; 2018 and 2023-24 wave names with actual country dates retained | Data-use terms allow reuse with attribution subject to third-party/specific restrictions. Retain OECD/OECD-WBG/OECD-ADB source labels. |
| World Bank | PIP API survey estimates | Release 20260922_2021_01_02_PROD; USD 3/day, 2021 PPP; fill_gaps=false | Public aggregate API; cite PIP, release and PPP year. No household microdata are obtained or redistributed. |
| Singapore Department of Statistics | M810361 and M810871 API tables | Provider update date retained; Gini originally 0-1 | Official public API. Cite the table IDs, exact series and update date. General and API terms are linked below; no broader license is inferred. |
| Hong Kong Census and Statistics Department | 2021 census household-income thematic report, Table 6.1 | Published May 2023; six values for 2011/2016/2021 | Official public report. Six transcribed values are kept separately with the page, definitions and visual verification note. No raw redistribution permission is claimed. |

The project is local research. These notes are source-use documentation, not a legal certification. Preserve attribution and review any specific conditions before publication. Raw provider files remain excluded from Git by the existing ignore rule.

## Official source links

- IMF current dataset landing page: https://data.imf.org/Datasets/ICSD
- IMF collected workbook: https://infrastructuregovern.imf.org/content/dam/PIMA/Knowledge-Hub/dataset/IMFInvestmentandCapitalStockDataset2021.xlsx
- IMF methods manual: https://data.imf.org/-/media/iData/External-Storage/Documents/A4922D1ABE9C49E0AFDEC821395FE59C/en/InvestmentandCapitalStockDatabaseUserManualandFAQ_May2021.pdf
- IMF general terms (web verification blocked): https://www.imf.org/external/terms.htm
- OECD PMR: https://www.oecd.org/en/topics/product-market-regulation.html
- OECD collected workbook: https://www.oecd.org/content/dam/oecd/en/topics/policy-sub-issues/product-market-regulation/PMR_Econwide_Indicator_2023-24_and_2018.xlsx
- OECD data terms, section 3: https://www.oecd.org/en/about/terms-conditions.html
- PIP API documentation: https://pip.worldbank.org/api
- Official PIP R client and definitions: https://github.com/worldbank/pipr
- PIP welfare/comparability methodology: https://datanalytics.worldbank.org/PIP-Methodology/welfareaggregate.html
- Singapore employment-income table: https://tablebuilder.singstat.gov.sg/table/TS/M810361
- Singapore market-income table: https://tablebuilder.singstat.gov.sg/table/TS/M810871
- Singapore API documentation: https://tablebuilder.singstat.gov.sg/view-api/for-developers/test
- Singapore terms: https://www.singstat.gov.sg/terms-of-use
- Hong Kong source PDF: https://www.census2021.gov.hk/doc/pub/21c-Household-Income.pdf

## Where the audit is saved

- metadata/fiscal_social_source_manifest.csv: download URLs, versions, local file times, attribution and checksums.
- metadata/imf_investment_definitions.csv: original variable descriptions.
- metadata/imf_country_crosswalk.csv: exact code matches and exclusions.
- metadata/pmr_workbook_headers.csv: original indicator-column labels.
- metadata/singapore_gini_table_definitions.csv: source populations, provider dates and full table notes.
- metadata/hong_kong_gini_transcription.csv: curated six-row source transcription with page references.
- outputs/source_checks/hong_kong_gini_table.png: visually reviewed original table image.
- outputs/tables/intervention_social_case_coverage.csv: an explicit row for every selected case.
- outputs/tables/wdi_pip_gini_same_year_audit.csv: same-year source differences with welfare labels; no automatic substitution.

## Remaining measurement gaps

The collected IMF workbook is an older, clearly identified vintage, not the latest ICSD release. A new release should be added as a separate audited vintage. Public investment misses government holding-company ownership, public-company activities outside general government, directed credit and industrial-policy tools. OECD assessments are periodic and have incomplete case coverage. NIPO/GTA remains a candidate for a later policy-event audit; policy counts cannot be treated as intervention intensity without further work.

PIP survey harmonization is useful but incomplete across countries. Income, consumption, coverage, population and reference periods still matter. Singapore and Hong Kong local measures fill a descriptive case-study gap, not the missing globally harmonized panel cells. Housing affordability, working hours, mobility and other social dimensions still need separate source audits. No social composite is forced merely to fill the fifth category.
