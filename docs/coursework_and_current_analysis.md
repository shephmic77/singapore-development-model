# How the course papers connect to the current analysis

The supplied papers and slides explain the project's original research question and design. This note links that work to the current R project. It distinguishes proposals and research leads from completed analyses, without changing the original documents.

## Research question

The topic paper asks how transferable the ideas behind Singapore's development approach are. Its argument is conditional: similar policy ideas may produce different outcomes where institutional capacity, history, resources, and political conditions differ. Paper 2 also asks whether apparent economic success comes with different political or social outcomes.

The present country-year analysis can describe trajectories and estimate conditional associations. It does not establish that another country adopted a coherent Singapore model or identify the causal effect of transferring it. Policy adoption, implementation, and appropriate counterfactuals still need evidence.

## Proposed hypotheses and current evidence

The following numbering refers specifically to Paper 2. The earlier presentation uses different H1-H3 labels.

| Paper 2 hypothesis | What the current project provides | What is still needed |
| --- | --- | --- |
| H1: Stronger state capacity is associated with improved economic and human development | Government-effectiveness measures and controlled annual outcome models | A clearly prespecified capacity test, interpretation of uncertainty, and attention to confounding and measurement |
| H2: Government-directed development has stronger benefits where institutions can implement it | Separate ownership/control and public-investment measures, with effectiveness as a control | An explicitly designed interaction or other conditional-effect test, adequate variation, and better policy-implementation evidence; current ownership coefficients do not test this interaction |
| H3: Similar-income countries differ in freedom and wellbeing | Separate outcomes, country comparisons, and income/region/reference sensitivities | A specified comparable-income comparison and careful timing and coverage; the existing plots are relevant descriptive evidence, not a completed causal test |

These are proposed research claims. Their presence in a paper does not mean this repository has established them.

## Five proposed categories and actual measures

The methods paper proposes economic performance, living standards, happiness, freedom/governance, and social/distributional outcomes. It introduces z-scores, reverses indicators where lower is better, and proposes equal weighting.

The implemented workflow is more selective. Economic and living-standard baskets are provisional, with stated component coverage and sensitivity checks. Happiness uses published multi-year life-evaluation periods rather than invented annual observations. The freedom basket remains descriptive and is separated from democracy regressions where components overlap. Social measures remain separate observed surveys, standardized inequality summaries, and gender inequality; there is no universal social composite. Government effectiveness is an institutional predictor rather than simply another freedom component.

Housing affordability, mobility, working hours, and other proposed measures are not assumed complete because they appear in the methods proposal. Check the current source guides and coverage tables. The proposal's short `scale()` example explains standardization; it is not the final reference construction or validation workflow.

## Case selection and historical periods

The early notes include Vietnam in two eras and do not list Zambia. The current eleven-case analysis includes Zambia and does not include Vietnam as a primary case. This difference is documented here; it does not establish when or why the case decision changed.

Several early cases focus on the 1960s-1990 period, while El Salvador is framed as a more recent comparison. Current source coverage varies substantially. Modern observations and the 2016 common-year inequality chart cannot be presented as evidence covering every proposed historical era. A focused historical case design still needs explicit justification and source coverage.

The early good/neutral/bad and similar/different labels are planning categories. They have not been imported as outcome values, treatment indicators, or training labels. They must not determine the reported results in advance.

## Literature and source evidence

The literature review supplies the conceptual bridge between state-led development, state capacity, political freedoms, and development beyond GDP. The source-links document and prior PDF inventory help organize further reading. They do not independently validate the cited articles' findings.

The inventory distinguishes publications listed in papers, additional discussion leads, candidate data portals, and unresolved items. Retain those distinctions. For actual dataset collection, use the current source manifests, country crosswalks, coverage tables, and source-specific methods documents.

Two different Huff 1995 papers appear in the materials; do not merge their titles. The APA record remains unidentified in the supplied inventory, and several discussion citations still need complete bibliographic verification. Original URLs, including a university-library proxy URL, are retained as supplied in the source-link index. No access restriction has been bypassed and no article content is represented as newly verified here.

## Practical next research decisions

1. Decide whether the main paper prioritizes broad development comparisons or a narrower test of policy transfer under different institutional conditions.
2. Define a test of Paper 2's capacity hypothesis before interpreting an ownership coefficient as evidence for it.
3. Justify the final case list and distinguish historical comparisons from modern descriptive snapshots.
4. Verify the bibliography against publisher or author records before final submission. Keep discussed sources separate from collected datasets.

The Pokemon exercise remains separate coursework. It does not enter these decisions or the Singapore bibliography.

## Read the original materials

See the [coursework index](../coursework/README.md), [filename and checksum manifest](../coursework/document_manifest.csv), and [extracted source links](../metadata/coursework_source_links.csv). For implemented choices, start with [current measure methods](better_measure_methods.md) and [source decisions](better_measure_sources.md).
