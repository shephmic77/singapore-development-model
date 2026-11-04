source('scripts/text_encoding.R')
# Human-readable copies and figures. Internal analysis files keep stable machine keys.
# Run from the project root; this script uses existing outputs and makes no downloads.
catalog <- read.csv('metadata/indicators.csv', stringsAsFactors=FALSE)
definitions <- read.csv('metadata/source_definitions.csv', stringsAsFactors=FALSE)
if(file.exists('metadata/additional_indicators.csv'))catalog<-rbind(catalog,read.csv('metadata/additional_indicators.csv',stringsAsFactors=FALSE))
if(file.exists('metadata/additional_source_definitions.csv'))definitions<-rbind(definitions,read.csv('metadata/additional_source_definitions.csv',stringsAsFactors=FALSE))
countries <- read.csv('metadata/countries.csv', stringsAsFactors=FALSE)
cases <- read.csv('metadata/primary_cases.csv', stringsAsFactors=FALSE)
dir.create('data/readable',showWarnings=FALSE)
dir.create('outputs/readable_tables',showWarnings=FALSE)
write_csv <- function(x,path) write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')
lookup <- function(keys, map) { out<-unname(map[as.character(keys)]); out[is.na(out)]<-as.character(keys)[is.na(out)];out }
indicator_names <- setNames(catalog$name,catalog$code)
official_names <- setNames(definitions$original_name, definitions$code)
units <- setNames(catalog$unit,catalog$code)
category_names <- c(economic='Economic performance',living='Living standards',social='Social and distributional outcomes',
 happiness='Happiness and well-being',freedom='Freedom and governance',openness='Market openness',capacity='Government effectiveness',
 intervention='Government economic involvement (context only)',controls='Control variables')
model_names <- c(pooled_year_FE='Year effects only',country_year_FE='Country and year effects')
term_names <- c('(Intercept)'='Model intercept',lag_trade='Trade share in previous year (percentage points of GDP)',
 lag_effectiveness='Government effectiveness in previous year (estimate units)',
 'log(lag_income)'='Log GDP per capita in previous year',
 'log(lag_population)'='Log population in previous year',
 lag_income='GDP per capita in previous year (constant 2021 international dollars)',
 lag_population='Population in previous year (people)')
# Technical identifiers remain alongside labels so readers can trace the source.
column_labels <- c(iso3='Country or economy code (ISO3)',year='Observation year',code='Source indicator code',
 name='Country or economy name',region='World Bank region',current_income_group='Current income group (not historical membership)',
 value='Observed value (see Measurement unit)',primary_case='One of the 11 selected cases',source_update='Source update date',
 transformed='Transformed value (see Transformation)',z='Annual relative score (z-score; higher means better)',
 percentile='Annual percentile (higher means better)',category='Development category',
 n_available='Indicators with usable scores',n_planned='Indicators planned in category',minimum='Minimum indicators required',
 score='Provisional category score (mean of available z-scores)',basket='Indicator codes actually included',
 n_observed='Economies with observed values',n_reference='Economies in reference catalog',missing_share='Missing share (0 to 1)',
 n_raw='Economies with raw values',n_transformed='Economies with transformed values',raw_mean='Unweighted mean of observed values',
 raw_sd='Standard deviation of observed values',transformed_mean='Mean after transformation',transformed_sd='Standard deviation after transformation',
 eligible='Meets annual normalization coverage and variation gate',
 dropped='Indicator omitted in sensitivity check',full_score='Score using complete indicator basket',
 leave_one_out='Score after omitting one indicator',baseline_year='Fixed reference year',
 fixed_2010_z='Score relative to fixed 2010 reference',n='Observation count (see file guide)',
 mean='Unweighted reference mean (see file guide)',sd='Reference standard deviation (see file guide)',
 group='Reference group membership definition',variable='Indicator or predictor',term='Model predictor',model='Model specification',
 estimate='Estimated association (coefficient)',cluster_se='Standard error clustered by country or economy',
 lower='Lower bound of 95 percent confidence interval',upper='Upper bound of 95 percent confidence interval',
 economies='Number of countries and economies',r_squared='R squared (model fit; not causal evidence)',
 condition_number='Design matrix condition number',breusch_pagan_p='Heteroskedasticity diagnostic p value',
 max_cooks_distance='Largest Cooks influence distance',within_sd='Within-country standard deviation',status='Availability status',
 error='Collection error message', 'is.na(value)'='Share of requested years with missing values',
 'is.finite(score)'='Selected cases with usable category score',
 lag_trade='Trade share in previous year (percent GDP)',lag_effectiveness='Government effectiveness in previous year (estimate)',
 lag_income='GDP per capita in previous year (constant 2021 international dollars)',lag_population='Population in previous year (people)')
column_labels<-c(column_labels,
 country_text_id='Original V-Dem country code',country_name='Original V-Dem country name',
 period_end_year='Last year in reporting period',period_start_year='First year in reporting period',period_label='Survey reporting period',
 report_year='Report publication year',provider_country='Provider country or economy name',provider_rank='Published rank (not the life-evaluation score)',
 life_evaluation_score='Average life evaluation (0-10 ladder; multi-year period)',
 lower_95='Provider lower 95 percent confidence bound',upper_95='Provider upper 95 percent confidence bound',
 provider_lower='Provider lower uncertainty bound (V-Dem)',provider_upper='Provider upper uncertainty bound (V-Dem)',provider_sd='Provider uncertainty standard deviation (V-Dem)',
 reference_n='Reference economies with observations',reference_mean='Unweighted reference mean',reference_sd='Reference standard deviation',
 outcome='Outcome being studied',variant='Model specification or sensitivity',democracy='Electoral democracy (predictor year; 0-1)',
 trade='Trade (predictor year; percent GDP)',effectiveness='Government effectiveness (predictor year; estimate units)',
 log_income='Log PPP GDP per capita (predictor year)',log_population='Log population (predictor year)',tariff='Applied tariff (predictor year; percent)',
 predictor_year='Year of explanatory variables',observed_outcome_rows='Rows with observed outcome before predictor filtering',
 complete_model_rows='Complete country-year rows used',first_year='First outcome year',last_year='Last outcome year',
 residual_predictor_sd='Predictor standard deviation after removing fixed effects',vif='Variance inflation factor after removing fixed effects',
 living_available_basket='Living standards (available-indicator provisional score)',living_fixed_basket='Living standards (fixed three-indicator score)',
 freedom_descriptive_score='Freedom (descriptive three-index score)',economic_growth='Real GDP per capita growth (annual percent)',
 match_year='First observed qualifying year',matched_income='PPP GDP per capita in qualifying year (constant 2021 dollars)',
 life_expectancy='Life expectancy in qualifying year (years)',benchmark_income='Singapore 2000 income benchmark (constant 2021 PPP dollars)')
term_names<-c(term_names,democracy='Electoral democracy (0-1)',trade='Trade share (percent GDP)',
 effectiveness='Government effectiveness (estimate units)',log_income='Log PPP GDP per capita',log_population='Log population',tariff='Weighted applied tariff (percent)')
file_notes<-NULL
# Dynamic series labels use the provider's exact title, including PPP base year/poverty threshold.
for(code in catalog$code) {
  label<-official_names[[code]]
  if(is.null(label)||is.na(label)||!nzchar(label))label<-indicator_names[[code]]
  column_labels[code]<-label
  column_labels[make.names(code)]<-label
  for(suffix in c('_codelow','_codehigh','_sd'))column_labels[paste0(code,suffix)]<-paste(label,switch(suffix,'_codelow'='provider lower uncertainty bound','_codehigh'='provider upper uncertainty bound','_sd'='provider uncertainty standard deviation'))
}
labels_for<-function(d) {
 map<-column_labels
 if(all(c('welfare_type','headcount','mean') %in% names(d))) {
  map['mean']<-'Average daily household welfare per person (2021 PPP dollars)'
  map['median']<-'Median daily household welfare per person (2021 PPP dollars)'
  map['country_name']<-'PIP country or economy name'
  map['year']<-'Survey reporting year'
 }
 if(all(c('gini_disp','gini_mkt') %in% names(d)))map['country']<-'Original SWIID economy name'
 if('igov_n' %in% names(d))map['income']<-'Country grouping in IMF workbook (not historical WB income group)'
 if('predictor_year' %in% names(d)) {
  map['income']<-'GDP per capita in predictor year (constant 2021 PPP dollars)'
  map['population']<-'Population in predictor year (people)'
 }
 map
}
readable <- function(d) {
  if('iso3' %in% names(d) && !'name' %in% names(d))
    d<-cbind(d['iso3'],country_or_economy_name=countries$name[match(d$iso3,countries$iso3)],d[setdiff(names(d),'iso3')])
  if('code' %in% names(d)) {
    d$indicator_name<-lookup(d$code,indicator_names)
    d$official_indicator_definition_title<-lookup(d$code,official_names)
    d$measurement_unit<-lookup(d$code,units)
    d$transformation<-catalog$transform[match(d$code,catalog$code)]
    d$indicator_limitation<-catalog$limitation[match(d$code,catalog$code)]
    d$better_outcome_direction<-c('Higher is better','Lower is better','No automatic better direction')[match(catalog$direction[match(d$code,catalog$code)],c(1,-1,0))]
  }
  if('outcome' %in% names(d))d$outcome<-lookup(d$outcome,c(economic_growth='Real GDP per capita growth',living_available_basket='Living standards: available-indicator basket',living_fixed_basket='Living standards: fixed three-indicator basket',freedom_descriptive_score='Freedom: descriptive basket',happiness_life_evaluation='Life evaluation: non-overlapping multi-year periods',gini_0_100='Gini inequality (0-100 points)',poverty_3usd_pct='Poverty below USD 3 per day (percent; 2021 PPP)',gender_inequality_index='Gender Inequality Index (0-1; lower = less inequality)'))
  if('variant' %in% names(d))d$variant<-lookup(d$variant,c(year_effects_only='Year effects only',country_year_effects='Country and year effects',without_income_control='Country and year effects; income control omitted',tariffs_instead_of_trade='Country and year effects; tariffs replace trade',exclude_singapore_hong_kong='Country and year effects; Singapore and Hong Kong excluded'))
  if('category' %in% names(d))d$category<-lookup(d$category,category_names)
  if('basket' %in% names(d))d$included_indicator_names<-vapply(strsplit(ifelse(is.na(d$basket),'',d$basket),';',fixed=TRUE),function(x)paste(lookup(x,indicator_names),collapse='; '),character(1))
  if('peer_type' %in% names(d))d$peer_type<-lookup(d$peer_type,c(historical_income_group='Historical income classification (July 1)',region='Current geographic region definition'))
  if('model' %in% names(d))d$model<-lookup(d$model,model_names)
  if('term' %in% names(d))d$term<-lookup(d$term,term_names)
  if('dropped' %in% names(d))d$dropped<-lookup(d$dropped,indicator_names)
  if('variable' %in% names(d))d$variable<-lookup(lookup(d$variable,indicator_names),term_names)
  names(d)<-lookup(names(d),labels_for(d))
  names(d)<-gsub('_',' ',names(d),fixed=TRUE)
  d
}
file_notes <- c(
 international_long='One row per country/economy, year and indicator. Values retain original units; blank means missing.',
 primary_cases_long='Same observed data restricted to the 11 selected cases. Hong Kong is a separately reported economy.',
 country_year_panel='One row per country/economy and year, with a separate labeled column for each observed indicator.',
 standardized_indicators='Raw values plus transformed values, annual z-scores and percentiles. At least 100 valid reference economies are required for scoring.',
 category_scores='Two provisional category scores. Zero is the mean of the reference-standardized components; positive is better. See basket and coverage columns.',
 fixed_baseline_sensitivity='Compares annual relative scores with scores anchored to the 2010 mean and standard deviation. Observation count refers to the 2010 indicator reference.',
 living_model_sample='Complete observations actually used in living-standard models. Predictors refer to exactly the preceding calendar year.',
 coverage_by_year='Coverage counts by indicator and year. Missing share uses the full reference catalog as denominator.',
 case_missingness='Missing share over all requested years 1965-2025 for each selected case and indicator.',
 global_reference='Annual indicator benchmarks. Raw statistics retain original units; transformed statistics reflect the stated transformation.',
 leave_one_out='Sensitivity for complete baskets only. Compares full-category score with a score omitting the named indicator.',
 primary_case_recent_scores='Selected-case provisional scores for 2015-2025. Use same-year comparisons and inspect changing basket composition.',
 primary_case_score_coverage='Number of the 11 selected cases with a usable category score in each year.',
 withheld_categories='Categories with no approved composite score yet. No missing score is replaced with zero.',
 correlations='Pairwise correlations from country-year observations since 2000. Diagonal equals 1. This is association, not causation.',
 correlation_sample_sizes='Number of jointly observed country-year pairs behind each correlation.',
 reduced_model_coefficients='Living-standard model estimates and 95 percent country-clustered confidence intervals. Observation count is country-year rows.',
 model_diagnostics='Sample size, model fit, heteroskedasticity and influence diagnostics. These do not establish causality.',
 within_country_variation='Standard deviation after subtracting each economy mean; predictor units are unchanged.',
 current_high_income_reference='Raw annual means for economies classified as high income today. This is not historical high-income membership. Observation count is economies.',
 modern_coverage_summary='Average annual observed-economy count and missing share across 2000-2025, including incomplete recent reporting.',
 collection_failures='Any failed collection requests in the latest pipeline run; a header-only file means no failures.')
file_notes<-c(file_notes,
 vdem_country_year='Audited V-Dem v16 country-year indices, original IDs and uncertainty. Historical raw values are retained; modern benchmarking begins in 2000.',
 vdem_indicators_and_scores='V-Dem raw values and annual scores using at least 100 matched reference economies. Provider bounds are not labeled as 95 percent intervals.',
 freedom_category_scores='Descriptive freedom basket: civil liberties, expression and association. All three are required. It shares ingredients with democracy and cannot independently test democracy effects.',
 happiness_period_scores='Observed 0-10 life-evaluation averages for explicitly labeled multi-year periods. Rank is separate. Early period start is left unassigned.',
 expanded_country_year_panel='World Bank country-year panel joined to reviewed V-Dem identifiers. Happiness is deliberately excluded because its observations cover multiple years.',
 expanded_analysis_panel='Annual outcomes, original indicators and fixed-basket living-standard sensitivity used in the expanded models.',
 happiness_nonoverlapping_model_panel='Non-overlapping happiness reporting windows. Predictors precede the full window, not just its ending year.',
 vdem_reference_by_year='Annual means, standard deviations and coverage for the matched modern V-Dem reference population.',
 expanded_model_coefficients='Expanded model estimates and country-clustered 95 percent confidence intervals. Outcome units differ, so coefficients across outcomes are not directly comparable.',
 expanded_model_diagnostics='Sample size, time window and basic model diagnostics. All models remain exploratory associations.',
 expanded_model_samples='Country/economy, outcome year and predictor year for every expanded model sample.',
 expanded_model_selections='Observed-outcome rows compared with complete-case model rows. Differences show sample loss from missing predictors.',
 expanded_model_vifs='Collinearity and residual predictor variation after removing each model fixed-effect structure.',
 calendar_year_case_comparisons='Observed values for selected cases in 1990, 2000, 2010, 2020 and 2024. A missing requested year remains blank.',
 development_stage_comparison='Exploratory stage alignment to Singapore 2000 PPP income, requiring a sustained three-year threshold and at most 10 percent initial overshoot. Earliest-observation matches are left-censored.',
 five_category_status='Plain-language status for all five outcome categories: available data, current modeling and unresolved limits.')
file_notes<-c(file_notes,
 historical_income_classifications='Official income group in force on July 1 of each observation year. Fiscal year and underlying GNI data year are separate. Starred retrospective classifications are excluded.',
 historical_and_regional_references='Raw annual indicator means and standard deviations using historical income groups or current geographic regions. Counts show membership and observed coverage; no peer z-scores are assumed.',
 singapore_peer_comparisons='Singapore compared with its historical income group and current geographic region, in original indicator units. Positive differences are not always better.',
 balanced_reference_2000_2024='Same economies with observed values in all 25 years for each indicator. Balanced selection can exclude data-poor economies and is not a representative global sample.',
 five_area_comparison='Relative scores for the 11 cases. Annual categories refer to 2024; life evaluation refers to 2022-2024. Social scores are unavailable.')
column_labels<-c(column_labels,fiscal_year='World Bank fiscal year',gni_data_year='Underlying GNI data year',
 historical_income_group='Historical income group (July 1 classification)',classification_code='Original published income classification code',
 peer_type='Type of reference group',peer_group='Reference group name',
 singapore_minus_peer_mean='Singapore minus peer mean (original units; sign is not automatically desirable)')
file_notes<-c(file_notes,additional_source_coverage='Coverage by V-Dem index/year and happiness reporting period. Observed counts refer to matched economies, not individual survey respondents.')
column_labels<-c(column_labels,source='Data source',indicator='Source indicator code',period='Observation year or reporting period',reference_catalog='Matched reference catalog (all periods)')
file_notes<-c(file_notes,
 imf_public_investment='Original IMF fields plus general-government investment / same-source nominal GDP. May 2021 vintage ends in 2019. Narrow fiscal measure, not total intervention.',
 oecd_public_ownership_assessments='Periodic ownership-regulation scores with actual legal-reference dates. Wave names are not assumed to be the observation year. No annual filling.',
 pip_survey_social_outcomes='Pinned PIP survey records with welfare concept, geography, comparability spell and unit conversions. Includes non-national records for inspection.',
 pip_national_social_outcomes='Strictly nationally labeled survey records, without interpolation. Income and consumption remain distinct.',
 singapore_gini_definitions='Official Singapore Gini definitions, populations, equivalence scales and tax treatments. A separate local case study, never spliced into PIP.',
 hong_kong_census_gini='Six verified census Gini values for two household populations and 2011/2016/2021. Printed page 98, PDF page 110; separate local case study.',
 public_investment_analysis_panel='Annual outcomes with exact preceding-year public investment and institutional predictors. Investment vintage ends in 2019.',
 social_survey_analysis_panel='Observed national surveys joined to preceding-year predictors, with comparable-spell identifiers retained. Gaps are not filled.',
 intervention_social_case_coverage='All 11 cases, showing usable investment years, OECD assessment dates, PIP concept/coverage and local source status.',
 intervention_social_measure_decisions='Simple source-by-source decisions: what is usable, what question it measures and what remains unresolved.',
 public_investment_coverage_by_year='Economies with usable same-source nominal investment/GDP ratios, by year.',
 social_references_by_welfare_type='Survey-year reference means, separating income and consumption. These are raw survey comparisons, not a global composite.',
 wdi_pip_gini_same_year_audit='Same-year candidate WDI/PIP Gini comparisons. Different vintages or welfare concepts can produce different values; no automatic substitution.',
 fiscal_social_model_coefs='New narrow-investment and social-survey model estimates, with country-clustered 95 percent confidence intervals and explicit outcome concepts.',
 fiscal_social_model_diagnostics='Model sample, window, fixed-effect structure, influence and heteroskedasticity diagnostics. Exploratory, not causal validation.',
 fiscal_social_model_membership='Exact country/economy-year membership of each new model; paired baseline/investment models use identical rows.',
 fiscal_social_model_selections='Sample losses, comparability-block counts, sample gates and estimation status for the new models.',
 fiscal_social_model_vifs='Collinearity and remaining predictor variation after each model fixed-effect structure.',
 public_investment_association_summary='Main same-sample investment coefficients with readable outcome units. Each coefficient refers to +1 percentage point of GDP in prior-year government investment.')
column_labels<-c(column_labels,
 government_investment_pct_gdp='General-government fixed investment (percent of GDP)',public_investment='Previous-year government fixed investment (percent of GDP)',
 isocode='Original IMF country code',ifscode='IMF IFS economy code',country='Original IMF economy name',
 igov_n='Government investment (billions of nominal local currency)',GDP_n='GDP (billions of nominal local currency)',
 kgov_n='Government capital stock (billions of nominal local currency)',ipriv_n='Private investment (billions of nominal local currency)',
 kpriv_n='Private capital stock (billions of nominal local currency)',kppp_n='PPP-project capital stock (billions of nominal local currency)',
 igov_rppp='Government investment (billions of constant 2017 international dollars)',GDP_rppp='GDP (billions of constant 2017 international dollars)',
 kgov_rppp='Government capital stock (billions of constant 2017 international dollars)',ipriv_rppp='Private investment (billions of constant 2017 international dollars)',
 kpriv_rppp='Private capital stock (billions of constant 2017 international dollars)',ippp_rppp='PPP-project investment (billions of constant 2017 international dollars)',
 kppp_rppp='PPP-project capital stock (billions of constant 2017 international dollars)',
 assessment_wave='Provider assessment-wave label (not necessarily observation year)',legal_reference_date='Date of laws and regulations assessed',legal_reference_year='Year of laws and regulations assessed',
 in_main_annual_window='Legal-reference date is no later than 2024',state_involvement_score='PMR regulatory distortions from state involvement (0-6)',
 public_ownership_distortion_score='PMR regulatory distortions from public ownership (0-6)',
 reporting_year='Provider survey reporting year',reporting_level='Reporting geography',survey_coverage='Survey population coverage',survey_year='Provider survey time (may be fractional year)',
 survey_acronym='Provider survey identifier',welfare_type='Welfare measured as income or consumption',survey_comparability='Provider comparability-spell ID (0 is first; not a quality score)',
 comparable_spell='Provider comparable-survey period',comparability_block='Within-country comparability block used for analysis',national_eligible='Meets nationally labeled survey filters',
 poverty_line='Poverty threshold (2021 PPP dollars per person per day)',ppp_base_year='Purchasing-power-parity reference year',
 headcount='Population below poverty threshold (fraction 0-1)',poverty_gap='Poverty gap (fraction)',poverty_severity='Poverty severity (fraction)',
 gini='Original PIP Gini (0-1)',gini_0_1='Original Gini (0-1)',gini_0_100='Gini inequality index (0-100)',
 poverty_3usd_pct='Population below USD 3 per day (percent; 2021 PPP)',bottom_40_share_pct='Welfare share held by poorest 40 percent (percent)',
 top_10_share_pct='Welfare share held by richest 10 percent (percent)',distribution_type='Source distribution type',estimation_type='Survey or other estimation type',
 reporting_pop='Population represented by provider reporting estimate',ppp='Provider PPP conversion factor',cpi='Provider consumer-price adjustment factor',
 table_id='Official Singapore table ID',series_id='Official Singapore series ID',original_series_name='Exact original provider series title',
 household_population='Household population represented',equivalence_scale='Household-size adjustment convention',tax_transfer_treatment='Tax and transfer accounting convention',
 provider_update_date='Provider last-update date',source_table='Original report table number',printed_page='Printed source page',pdf_page='PDF page number',
 public_investment_years='Years with usable public-investment observations',public_investment_last_year='Last observed public-investment year',
 pmr_assessments='Available PMR assessments',pmr_legal_dates='Actual PMR legal-reference dates',pip_all_survey_rows='PIP survey records across all coverage types',
 pip_national_survey_rows='PIP records passing national-survey filters',pip_welfare_types='Available PIP welfare concepts',pip_status='PIP coverage status',
 local_gini_status='Separate official local Gini source status',gini_mean_0_100='Mean survey Gini within this welfare concept (0-100)',
 poverty_mean_pct='Mean survey poverty rate within this welfare concept (percent)',wdi_gini_0_100='WDI Gini (0-100; same-year candidate)',
 wdi_minus_pip='WDI minus PIP Gini (index points; not proof of equivalent concepts)',comparability_blocks='Number of eligible comparable-survey blocks')
column_labels<-c(column_labels,n_valid_gini='Economies with a valid Gini observation',n_valid_poverty='Economies with a valid poverty observation',
 gini_sd_0_100='Standard deviation of Gini in this welfare group (0-100 points)',poverty_sd_pct='Standard deviation of poverty in this welfare group (percentage points)',
 coefficient_and_interval='Coefficient and country-clustered 95 percent confidence interval',coefficient_unit='How to interpret one coefficient unit',
 outcome_label='Outcome and measurement unit',sample_definition='Years and eligibility rules used for this model')
for(i in 1:10)column_labels[paste0('decile',i)]<-paste0('Welfare share held by population decile ',i,' (fraction 0-1)')
term_names<-c(term_names,public_investment='Previous-year government fixed investment (percent GDP)')
if(file.exists('outputs/tables/fiscal_social_model_coefs.csv'))source('scripts/12_intervention_social_report.R')
file_notes<-c(file_notes,
 state_ownership_control='Expert-assessed ownership/direct control, original V-Dem values, reversed 0-4 expected scale and uncertainty. Not an asset percentage or a welfare score.',
 swiid_standardized_income_inequality='Published SWIID standardized/model-based disposable and market income estimates. Provider uncertainty retained; not direct survey data or regression-ready validated draws.',
 undp_gender_inequality='Same-vintage UNDP Gender Inequality Index, 1990-2023. Lower raw values mean less inequality; higher relative z means less relative disadvantage. Hong Kong remains missing.',
 ownership_outcome_analysis_panel='Annual growth, living and gender outcomes with exact preceding-year ownership and other predictors. SWIID outcomes are excluded from regression.',
 ownership_survey_analysis_panel='Observed national PIP survey outcomes with preceding-year ownership, separate welfare types and comparable-spell metadata.',
 ownership_social_case_coverage='All 11 cases with source-specific last years; different last years are not silently treated as simultaneous comparisons.',
 swiid_draw_format_audit='Diagnostic-only format/summary discrepancies. Trial division is not an accepted unit conversion. Draw-based regression is explicitly withheld.',
 swiid_same_year_case_comparison='All 11 cases in the latest common SWIID year, 2016. Provider-modeled income summaries with approximate uncertainty; no mixed latest years.',
 swiid_same_year_references='Unweighted same-year reference statistics of published standardized estimates, with observed economy count; not a direct-survey population mean.',
 gender_inequality_reference_by_year='Annual gender-index reference counts and raw mean/SD; relative scores require at least 100 observed economies.',
 better_measure_source_decisions='Accepted, limited and unavailable candidate sources, including dependent sources and the failed WIID public download.',
 ownership_model_coefs='Ownership/direct-control association models. Country-clustered 95 percent intervals are conditional on point predictor estimates.',
 ownership_model_diagnostics='Sample, time window, influence and heteroskedasticity diagnostics for new ownership models.',
 ownership_model_members='Exact model sample membership and predictor years; baseline and main ownership specification share identical rows.',
 ownership_model_selections='Model sample gates and estimation status, including observed-survey welfare concepts.',
 ownership_model_vifs='Predictor collinearity and remaining variation after removing the model fixed effects.',
 ownership_within_country_variation='Observed provider variation, distinct values and adjacent-year changes. Repeated scores do not prove unchanged real policy.',
 main_ownership_associations='Main country/year-effect ownership coefficients for growth, living standards and gender inequality; units differ by outcome.')
column_labels<-c(column_labels,
 ownership_control_0_4='State ownership/direct control (index 0-4; higher = more)',ownership_lower_bound='Provider lower ownership uncertainty bound (0-4)',
 ownership_upper_bound='Provider upper ownership uncertainty bound (0-4)',ownership_latent_reversed='Reversed latent ownership/control score (not 0-4 units)',
 v2clstown='Original V-Dem latent score (higher = less state control)',v2clstown_codelow='Original latent-score lower provider bound',v2clstown_codehigh='Original latent-score upper provider bound',
 v2clstown_sd='Original latent-score uncertainty standard deviation',v2clstown_osp='Original expected response scale (0-4; higher = less state control)',
 v2clstown_osp_codelow='Original response-scale lower provider bound',v2clstown_osp_codehigh='Original response-scale upper provider bound',
 v2clstown_osp_sd='Original response-scale uncertainty standard deviation',v2clstown_nr='Provider number of raters',
 state_control='Previous-year state ownership/direct control (index 0-4)',state_control_latent='Previous-year reversed latent ownership score',
 gini_disp='SWIID disposable-income Gini (0-100; modeled)',gini_mkt='SWIID market-income Gini (0-100; modeled)',
 gini_disp_se='Provider standard error of disposable-income Gini',gini_mkt_se='Provider standard error of market-income Gini',
 disposable_lower95='Approximate lower 95 percent provider uncertainty bound (disposable)',disposable_upper95='Approximate upper 95 percent provider uncertainty bound (disposable)',
 market_lower95='Approximate lower 95 percent provider uncertainty bound (market)',market_upper95='Approximate upper 95 percent provider uncertainty bound (market)',
 abs_red='Provider absolute redistribution estimate (Gini points; availability restricted)',abs_red_se='Provider uncertainty in absolute redistribution estimate',
 rel_red='Provider relative redistribution estimate (percent; availability restricted)',rel_red_se='Provider uncertainty in relative redistribution estimate',
 gender_inequality_index='UNDP Gender Inequality Index (0-1; lower = less inequality)',gender_relative_z='Relative gender score (higher = less inequality)',
 ownership_years='Years with ownership estimates',ownership_last_year='Last year with ownership estimate',swiid_years='Years with standardized income estimates',
 swiid_first_year='First year with standardized income estimate',swiid_last_year='Last year with standardized income estimate',gii_years='Years with gender-index values',gii_last_year='Last year with gender-index value',
 gii_status='Gender-index coverage status',n_draws='Number of supplied uncertainty draws',raw_min='Lowest raw draw value (diagnostic only)',raw_max='Highest raw draw value (diagnostic only)',
 max_gap_to_summary='Largest draw-mean gap from published summary (diagnostic)',max_gap_after_diagnostic_division100='Largest gap after trial division by 100 (diagnostic only; not accepted data)',
 ownership_sd='Within-country standard deviation of ownership score',distinct_provider_values='Distinct provider ownership scores',adjacent_year_changes='Adjacent-year changes in provider score',
 disposable_gini_mean='Mean standardized disposable-income Gini',disposable_gini_sd='SD of standardized disposable-income Gini',market_gini_mean='Mean standardized market-income Gini',market_gini_sd='SD of standardized market-income Gini')
term_names<-c(term_names,state_control='State ownership/direct control (index 0-4)',state_control_latent='State ownership/direct control (reversed latent units)')
if(file.exists('outputs/tables/ownership_model_coefs.csv'))source('scripts/15_better_measure_report.R')
# Generate additional small tables before cataloging every available output.
if(file.exists('outputs/tables/expanded_model_coefficients.csv'))source('scripts/08_current_report.R')
index<-list(); dictionary<-list()
for(folder in c('data/clean','outputs/tables')) for(path in list.files(folder,pattern='[.]csv$',full.names=TRUE)) {
  d<-read.csv(path,check.names=FALSE,stringsAsFactors=FALSE)
  r<-readable(d)
  target<-file.path(if(folder=='data/clean')'data/readable' else 'outputs/readable_tables',basename(path))
  write_csv(r,target)
  stem<-tools::file_path_sans_ext(basename(path))
  note<-if(stem %in% names(file_notes))file_notes[[stem]] else 'Research output; consult methodology for interpretation.'
  index[[length(index)+1]]<-data.frame(file=target,rows=nrow(r),what_it_contains=note)
  mapped<-lookup(names(d),labels_for(d))
  dictionary[[length(dictionary)+1]]<-data.frame(original_file=path,original_column=names(d),reader_label=mapped)
}
index<-do.call(rbind,index); write_csv(index,'metadata/output_catalog.csv')
write_csv(do.call(rbind,dictionary),'metadata/output_column_dictionary.csv')
# Readable captions and generous margins are part of every saved figure.
plot_file<-function(name,expr,width=1500,height=1000) {
  png(file.path('outputs/figures',name),width=width,height=height,res=140)
  tryCatch(force(expr),finally=dev.off())
}
coverage<-read.csv('outputs/tables/coverage_by_year.csv')
panel<-read.csv('data/clean/international_long.csv')
scores<-read.csv('data/clean/category_scores.csv')
cm<-xtabs(n_observed~code+year,coverage)
plot_file('coverage.png',{
  layout(matrix(c(1,2),nrow=1),widths=c(8,2))
  par(mar=c(5,19,5,1),oma=c(3,0,0,0))
  image(as.numeric(colnames(cm)),seq_len(nrow(cm)),t(cm),axes=FALSE,
    xlab='Calendar year',ylab='',col=hcl.colors(40,'YlGnBu'),zlim=c(0,nrow(countries)),
    main='How much data is available?')
  axis(1);axis(2,seq_len(nrow(cm)),lookup(rownames(cm),indicator_names),las=2,cex.axis=.8)
  mtext('Countries and separately reported economies with an observation, by indicator and year',side=3,line=.8,cex=.8)
  par(mar=c(5,0,5,4));image(1,0:nrow(countries),matrix(0:nrow(countries),nrow=1),
    col=hcl.colors(40,'YlGnBu'),axes=FALSE,xlab='',ylab='');axis(4,pretty(c(0,nrow(countries))),las=1,cex.axis=.8)
  mtext('Economies',side=3,line=.8,cex=.8)
  mtext('Source: World Bank WDI and WGI. Missing observations remain missing; coverage is not a quality rating.',side=1,outer=TRUE,line=1,cex=.8)
})
plot_file('singapore_life_expectancy.png',{
  par(mar=c(5,5,5,2),oma=c(3,0,0,0))
  d<-panel[panel$code=='SP.DYN.LE00.IN' & panel$iso3=='SGP',];d<-d[order(d$year),]
  g<-aggregate(value~year,panel[panel$code=='SP.DYN.LE00.IN',],mean)
  plot(d$year,d$value,type='l',lwd=3,col='#B33B35',xlab='Calendar year',ylab='Life expectancy at birth (years)',
    ylim=range(c(d$value,g$value),na.rm=TRUE),main='Life expectancy: Singapore and the international reference')
  lines(g$year,g$value,lty=2,lwd=2,col='#375A7F')
  legend('bottomright',c('Singapore','Mean across economies with data in that year'),col=c('#B33B35','#375A7F'),lty=c(1,2),lwd=c(3,2),bty='n',cex=.9)
  mtext('Observed measurements, not standardized scores',side=3,line=.8,cex=.85)
  mtext('Source: World Bank WDI (SP.DYN.LE00.IN). Reference mean is unweighted; its membership changes with coverage.',side=1,outer=TRUE,line=1,cex=.8)
})
plot_file('primary_case_category_trends.png',{
  layout(matrix(1:3,nrow=3),heights=c(.7,4,4))
  par(oma=c(4,0,0,0),mar=c(0,5,0,2)); colors<-hcl.colors(nrow(cases),'Dark 3')
  plot.new()
  legend('center',cases$name,col=colors,lty=1+(seq_len(nrow(cases))>8),lwd=2,ncol=4,cex=.85,bty='n')
  for(cat in c('economic','living')) {
    par(mar=c(6,5,3,2))
    d<-scores[scores$category==cat & scores$iso3 %in% cases$iso3,]
    plot(NA,xlim=c(1990,max(scores$year)),ylim=range(d$score,na.rm=TRUE),xlab='Calendar year',ylab='Provisional category score',
      main=paste0(lookup(cat,category_names),': comparison of the 11 selected cases'),cex.main=1)
    abline(h=0,col='gray65',lty=3)
    for(i in seq_len(nrow(cases))) {
      s<-d[d$iso3==cases$iso3[i],];s<-s[order(s$year),];lines(s$year,s$score,col=colors[i],lty=1+(i>8),lwd=2)
    }
    caption<-if(cat=='economic')'Income (PPP, logged) and unemployment (reversed); both required.' else 'Life expectancy, infant mortality (reversed, logged), education and electricity; at least 3 of 4 required.'
    mtext(caption,side=1,line=4.6,cex=.73)
  }
  mtext('Higher = better relative performance. Components use same-year international z-scores; category score is their mean.',side=1,outer=TRUE,line=1,cex=.8)
  mtext('Source: World Bank WDI. Available components and reference coverage can change. Hong Kong is a separately reported economy.',side=1,outer=TRUE,line=2.4,cex=.75)
},height=1400)
path<-'outputs/tables/reduced_model_coefficients.csv'
if(file.exists(path)) {
  d<-read.csv(path); d<-d[d$term!='(Intercept)',]
  titles<-c(lag_trade='Trade openness: previous-year trade share',lag_effectiveness='Government effectiveness: previous year',
    'log(lag_income)'='Income: log of previous-year GDP per capita','log(lag_population)'='Size: log of previous-year population')
  unit_captions<-c(lag_trade='Change per 1 percentage point of trade / GDP',lag_effectiveness='Change per 1 governance-estimate unit',
    'log(lag_income)'='Change per 1 log unit of PPP GDP per capita','log(lag_population)'='Change per 1 log unit of population')
  plot_file('reduced_model_coefficients.png',{
    par(mfrow=c(2,2),mar=c(6,5,5,2),oma=c(5,0,3,0))
    for(term in unique(d$term)) {
      s<-d[d$term==term,]
      plot(seq_len(nrow(s)),s$estimate,xlim=c(.4,nrow(s)+.6),ylim=range(c(0,s$lower,s$upper)),xaxt='n',pch=19,cex=1.3,
        xlab='',ylab='Change in living-standards category score',main=lookup(term,titles),cex.main=.95)
      arrows(seq_len(nrow(s)),s$lower,seq_len(nrow(s)),s$upper,angle=90,code=3,length=.08,lwd=2)
      axis(1,seq_len(nrow(s)),c('Year effects only','Country + year effects'),cex.axis=.8)
      abline(h=0,lty=2,col='gray55');mtext(lookup(term,unit_captions),side=1,line=3.6,cex=.75)
    }
    mtext('Exploratory associations with living standards',side=3,outer=TRUE,line=.8,font=2,cex=1.3)
    mtext('Dots = estimated coefficients; bars = 95% confidence intervals clustered by country/economy; dashed line = zero.',side=1,outer=TRUE,line=1,cex=.8)
    mtext(sprintf('Source: R models of World Bank data. %s country-year observations across %s economies. Associations do not establish causation.',format(d$n[1],big.mark=','),d$economies[1]),side=1,outer=TRUE,line=2.5,cex=.8)
  })
}
# Local HTML report provides one entry point for readers; no hosting or extra package needed.
escape<-function(x) {x<-gsub('&','&amp;',x,fixed=TRUE);x<-gsub('<','&lt;',x,fixed=TRUE);gsub('>','&gt;',x,fixed=TRUE)}
figures<-c(coverage='Data availability across indicators and years',singapore_life_expectancy='Singapore life expectancy versus the international mean',
 primary_case_category_trends='Economic performance and living standards across the 11 cases',reduced_model_coefficients='Exploratory regression coefficients and uncertainty')
html<-c('<!doctype html><html lang="en"><meta charset="utf-8"><title>SODA 308: Results guide</title>',
 '<style>body{font:17px/1.6 system-ui;max-width:1150px;margin:40px auto;padding:0 24px;color:#203040}img{width:100%;border:1px solid #ddd}table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:10px;text-align:left;vertical-align:top}a{color:#075b9e}small{color:#4d5968}</style>',
 '<h1>Singapore Development Model: Results Guide</h1>',
 '<p>This exploratory R project compares development outcomes using real World Bank data. Start with the charts below, then open the labeled CSV files.</p>',
 '<p><strong>How to read the scores:</strong> Higher means better relative performance. Zero is the mean of the components standardized against each year\'s available international reference. Category scores are averages of component z-scores, not standardized category distributions. These provisional scores do not prove policy effects.</p>',
 '<p>Happiness, freedom and social composites remain unavailable. The models omit democracy and a defensible state-intervention measure.</p>',
 '<h2>Plots</h2>')
for(f in names(figures))if(file.exists(file.path('outputs/figures',paste0(f,'.png'))))html<-c(html,
 paste0('<h3>',figures[[f]],'</h3><a href="figures/',f,'.png"><img alt="',figures[[f]],'" src="figures/',f,'.png"></a>'))
html<-c(html,'<h2>Labeled datasets and results tables</h2><p>Blank cells mean unavailable values, never zero. Each CSV has descriptive column headings. Keep source codes for traceability.</p>',
 '<table><tr><th>File</th><th>Rows</th><th>What it contains</th></tr>')
for(i in seq_len(nrow(index)))html<-c(html,paste0('<tr><td><a href="../',index$file[i],'">',escape(basename(index$file[i])),
 '</a></td><td>',format(index$rows[i],big.mark=','),'</td><td>',escape(index$what_it_contains[i]),'</td></tr>'))
html<-c(html,'</table><p>Sources: World Bank World Development Indicators and Worldwide Governance Indicators. Details, retrieval dates and original definitions are preserved in the project metadata and raw manifest.</p>',
 '<p><a href="../docs/output_guide.md">Output guide</a> | <a href="../metadata/output_column_dictionary.csv">Column dictionary</a> | <a href="../README.md">Reproduction instructions</a></p></html>')
writeLines(html,'outputs/START_HERE.html',useBytes=TRUE)
guide<-c('# Guide to datasets and plots','','Open `outputs/START_HERE.html` in a browser for a chart gallery and links to labeled datasets.',
 '', '## Which files should I use?',
 'Use `data/readable/` and `outputs/readable_tables/` for reading and sharing results. These copies include full country/economy names, descriptive headers, indicator titles and units. The original machine-readable files remain the inputs to the R analysis.',
 'Each observed-value row identifies its measurement unit and the exact provider title. For wide datasets, column headers use the provider title, including relevant PPP base years and poverty thresholds.',
 'The technical source codes are retained for traceability. A blank cell means missing or not eligible for scoring, not zero.',
 '', '## How to read the plots',
 '- Data availability: color shows the number of economies with observations; the numbered color bar gives the scale.',
 '- Life expectancy: raw years of expected life at birth; the comparison line is an unweighted available-economy mean.',
 '- Category trends: full country names, higher-is-better category means of annual indicator z-scores; a score of zero is the average of the standardized components, not a world ranking. Changing basket composition can affect trends.',
 '- Model estimates: dots show associations, bars show country-clustered 95% confidence intervals. A bar crossing zero is compatible with no association in that model. Predictor units differ, so panels have separate axes. The models cannot establish causal effects.',
 '', '## Dataset catalog','', '| File | Rows | What it contains |','| --- | ---: | --- |')
for(i in seq_len(nrow(index)))guide<-c(guide,paste0('| `',index$file[i],'` | ',index$rows[i],' | ',index$what_it_contains[i],' |'))
guide<-c(guide,'','## Column definitions',
 'See `metadata/output_column_dictionary.csv` for the mapping from technical column names to descriptive labels. `metadata/indicators.csv` records units, transformations, direction and limitations; `metadata/source_definitions.csv` preserves the exact original definition and provider.',
 'Raw and transformed values are different scales. Raw means and standard deviations retain indicator units. Annual z-scores use the same-year reference; fixed-2010 scores use the 2010 reference. Percentiles are 0-100 positions, not raw measurements.',
 'For model tables, observation counts mean country-year rows. For reference tables, counts mean economies. For fixed-baseline data, the count describes baseline economies. Missing share is a fraction from 0 to 1.',
 '', '## Regenerate these labels and plots',
 'In the RStudio console, run `source("scripts/05_reader_outputs.R")`. It reads existing data and does not download or refit models.')
writeLines(guide,'docs/output_guide.md')
message('Reader-friendly datasets, charts and outputs/START_HERE.html updated.')



if(file.exists('data/clean/freedom_category_scores.csv'))source('scripts/08_current_report.R')







if(file.exists('outputs/tables/fiscal_social_model_coefs.csv'))source('scripts/12_intervention_social_report.R')




if(file.exists('outputs/tables/ownership_model_coefs.csv'))source('scripts/15_better_measure_report.R')

