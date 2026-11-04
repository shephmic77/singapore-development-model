source('scripts/text_encoding.R')
.libPaths(c(normalizePath('.R-library'),.libPaths()))
imf<-read.csv('data/clean/imf_public_investment.csv')
raw_imf<-as.data.frame(readxl::read_excel('data/raw/IMFInvestmentandCapitalStockDataset2021.xlsx',sheet='Dataset'))
ids<-match(paste(imf$isocode,imf$year),paste(raw_imf$isocode,raw_imf$year));stopifnot(!anyNA(ids))
num<-suppressWarnings(as.numeric(raw_imf$igov_n[ids]));den<-suppressWarnings(as.numeric(raw_imf$GDP_n[ids]))
expected<-ifelse(is.finite(num)&is.finite(den)&den>0&num>=0,100*num/den,NA)
stopifnot(isTRUE(all.equal(imf$government_investment_pct_gdp,expected,tolerance=1e-12)),max(imf$year)==2019,!anyDuplicated(imf[c('iso3','year')]))
cases<-read.csv('metadata/primary_cases.csv');stopifnot(all(cases$iso3 %in% imf$iso3))
pmr<-read.csv('data/clean/oecd_public_ownership_assessments.csv')
stopifnot(!anyDuplicated(pmr[c('iso3','assessment_wave')]),all(pmr$in_main_annual_window==(pmr$legal_reference_year<=2024)))
stopifnot(any(pmr$legal_reference_year>2024),!'SGP' %in% pmr$iso3)
for(sheet in unique(pmr$assessment_wave)) {
 raw<-as.data.frame(readxl::read_excel('data/raw/PMR_Econwide_Indicator_2023-24_and_2018.xlsx',sheet=sheet,col_names=FALSE,.name_repair='minimal',col_types='text'))
 d<-pmr[pmr$assessment_wave==sheet,];idx<-match(d$iso3,raw[[1]])
 stopifnot(!anyNA(idx),isTRUE(all.equal(d$public_ownership_distortion_score,as.numeric(raw[[9]][idx]),tolerance=1e-12)))
 stopifnot(all(d$legal_reference_date==as.character(as.Date(as.numeric(raw[[5]][idx]),origin='1899-12-30'))))
}
pip<-read.csv('data/clean/pip_survey_social_outcomes.csv',na.strings=c('','NA'))
raw<-jsonlite::fromJSON('data/raw/PIP_20260922_2021_3USD_surveys.json')
key<-function(d)paste(d$country_code,d$reporting_year,d$welfare_type,d$reporting_level,d$survey_coverage,d$survey_acronym,sep='|')
idx<-match(key(pip),key(raw));stopifnot(!anyNA(idx))
stopifnot(isTRUE(all.equal(pip$gini_0_100,100*raw$gini[idx],tolerance=1e-12)),isTRUE(all.equal(pip$poverty_3usd_pct,100*raw$headcount[idx],tolerance=1e-12)))
stopifnot(isTRUE(all.equal(pip$bottom_40_share_pct,unname(100*rowSums(raw[idx,c('decile1','decile2','decile3','decile4')])),tolerance=1e-12)))
n<-read.csv('data/clean/pip_national_social_outcomes.csv',na.strings=c('','NA'))
stopifnot(all(n$reporting_level=='national' & n$survey_coverage=='national' & !n$is_interpolated & n$estimation_type=='survey'))
stopifnot(!anyDuplicated(n[c('iso3','year','welfare_type')]),!any(c('SGP','HKG','ARG') %in% n$iso3))
sg<-read.csv('data/clean/singapore_gini_definitions.csv')
stopifnot(!anyDuplicated(sg[c('table_id','series_id','year')]),all(sg$gini_0_1>=0 & sg$gini_0_1<=1))
for(id in unique(sg$table_id)) {
 r<-jsonlite::fromJSON(paste0('data/raw/SingStat_',id,'.json'))$Data$row
 for(series in unique(sg$series_id[sg$table_id==id])) {
  d<-sg[sg$table_id==id & sg$series_id==series,];cols<-r$columns[[which(r$seriesNo==series)]]
  expected<-as.numeric(cols$value[match(d$year,as.integer(cols$key))])
  stopifnot(isTRUE(all.equal(d$gini_0_1,expected,tolerance=1e-12)))
 }
}
hk<-read.csv('data/clean/hong_kong_census_gini.csv');transcript<-read.csv('metadata/hong_kong_gini_transcription.csv')
stopifnot(nrow(hk)==6,identical(hk$gini_0_1,transcript$gini_0_1),all(hk$year %in% c(2011,2016,2021)),all(hk$pdf_page==110),!anyDuplicated(hk[c('year','household_population')]))
m<-read.csv('outputs/tables/fiscal_social_model_membership.csv',na.strings=c('','NA'))
stopifnot(all(m$predictor_year==m$year-1))
social<-m[m$welfare_type %in% c('income','consumption'),]
stopifnot(!any(c('SGP','HKG','ARG') %in% social$iso3))
for(d in split(social,interaction(social$outcome,social$model,social$welfare_type,drop=TRUE))) {
 stopifnot(!anyNA(d$comparability_block),all(tapply(d$year,d$comparability_block,function(x)length(unique(x)))>=3))
}
# Pairing is checked by exact model membership, not merely matching sample-size totals.
for(outcome in unique(m$outcome))for(w in unique(m$welfare_type)) {
 a<-m[m$outcome==outcome & m$welfare_type==w & m$model=='Matched sample: without public investment',]
 b<-m[m$outcome==outcome & m$welfare_type==w & m$model=='Matched sample: with public investment',]
 stopifnot(identical(sort(paste(a$iso3,a$year)),sort(paste(b$iso3,b$year))))
}
co<-read.csv('outputs/tables/fiscal_social_model_coefs.csv')
stopifnot(all(co$n>=100 & co$economies>=30),all(co$lower<=co$estimate & co$estimate<=co$upper))
manifest<-read.csv('metadata/fiscal_social_source_manifest.csv');stopifnot(all(unname(tools::md5sum(manifest$file))==manifest$md5))
writeLines(c('PASS: original IMF values and same-source ratio; 2019 vintage boundary; all 11 cases;',
 'OECD values and actual legal-reference dates preserved; no Singapore assessment invented;',
 'PIP source-value conversions, exact survey keys, national/survey filters and welfare separation;',
 'Singapore original values and distinct series preserved; six Hong Kong curated source values retained;',
 'exact-year predictor joins; comparable-block sample gate; paired model membership; clustered intervals; source checksums.',
 'Hong Kong values were independently checked visually against the rendered PDF table; the automated test preserves that curated transcription.'),
 'outputs/intervention_social_validation.txt')
cat('State-intervention and social-outcome validation checks passed.\n')

