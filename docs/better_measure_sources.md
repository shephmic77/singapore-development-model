# Better measures: sources and decisions

| Candidate | Decision | Why |
| --- | --- | --- |
| V-Dem state ownership/direct control | Accepted as a distinct ownership component | Directly asks about important sectors; broad modern coverage; expert uncertainty retained |
| Fraser state-ownership component | Not treated as independent corroboration | Its documentation identifies V-Dem as its source |
| SWIID 9.92 summary | Descriptive standardized-income supplement | Common income/equivalence targets and published uncertainty; still provider-modeled |
| SWIID supplied uncertainty draws | Regression withheld | Unresolved scale/summary-concordance discrepancies; no guessed correction |
| UNDP Gender Inequality Index | Accepted as a separate social dimension | Standardized published definition, with missing values and overlap retained |
| WIID Companion, corrected September 2026 | Identified but not imported | Official workbook returned HTTP 403; no access restriction bypass or substitute copy used |

## Versions and source-use records

V-Dem uses the existing pinned Country-Year v16 files and codebook. Its CC BY-SA 4.0 attribution and derivative share-alike requirements remain applicable. The exact ownership question and response definitions are saved in metadata/state_ownership_definition.csv and state_ownership_response_guide.csv.

SWIID is version 9.92, April 2026, from Harvard Dataverse release 16.0, file ID 13657070. The official metadata identified CC0 1.0 and archive MD5 29fea15aa2dc73d757cf1775cf99e9c0, which was verified. Cite Solt (2020), “Measuring Income Inequality Across Countries and Over Time: The Standardized World Income Inequality Database,” with version 9.92 and April 2026. The source archive and summaries are unchanged. The diagnostic trial division is not used to alter outcome data.

UNDP uses HDR 2025 official time-series and metadata files. Exact citation guidance is exported from the metadata workbook. Only the GII series is selected from the large composite-index file. No unrestricted redistribution license is inferred from download availability; attribution and any applicable UNDP/source terms should be retained before publication.

New download URLs, versions, file times and checksums are in metadata/ownership_social_source_manifest.csv. Times are explicitly taken from local downloaded-file modification times. Existing V-Dem source provenance remains in the earlier additional-source manifest. Raw archives remain excluded from Git.

## Official links

- V-Dem data and terms: https://www.v-dem.net/data/the-v-dem-dataset/
- V-Dem official R repository: https://github.com/vdeminstitute/vdemdata
- Fraser documentation of its V-Dem-based ownership component: https://www.fraserinstitute.org/sites/default/files/2025-09/economic-freedom-of-the-world-2025-annual-report_0.pdf
- SWIID source and citation: https://fsolt.org/swiid/
- SWIID graphing/uncertainty guidance: https://fsolt.org/swiid/swiid_faq/posts/how-to/mean-and-std-err.html
- SWIID official deposit: https://doi.org/10.7910/DVN/LM4OWF
- SWIID pinned file: https://dataverse.harvard.edu/api/access/datafile/13657070
- UNDP downloads and methods: https://hdr.undp.org/data-center/documentation-and-downloads
- UNDP GII definition: https://hdr.undp.org/data-center/thematic-composite-indices/gender-inequality-index
- WIID corrected release and notes: https://www.wider.unu.edu/database/world-income-inequality-database-wiid

## How the sources differ

PIP remains the observed-survey foundation with explicit welfare and coverage labels. SWIID is a standardized/model-based supplement using sources that can include PIP and other survey collections; agreement between them is not independent validation. UNDP measures gender disadvantage and is not a replacement for monetary inequality. V-Dem measures expert-assessed ownership/control, while IMF public investment measures fiscal capital formation. Their different definitions are intentional and remain visible.

The newer corrected WIID release is not the same product or vintage as SWIID 9.92. Its corrections must not be assumed to have been incorporated into an earlier separate release. Any future import needs its own definition, coverage and provenance audit.
