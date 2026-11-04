source('scripts/text_encoding.R')
# Extended-source checks against original data and documented timing rules.
.libPaths(c(normalizePath('.R-library'),.libPaths()))
v<-read.csv('data/clean/vdem_country_year.csv');h<-read.csv('data/clean/happiness_period_scores.csv')
f<-read.csv('data/clean/freedom_category_scores.csv');cases<-read.csv('metadata/primary_cases.csv')
stopifnot(!anyDuplicated(v[c('iso3','year')]),!anyDuplicated(h[c('iso3','period_end_year')]))
stopifnot(all(cases$iso3 %in% v$iso3),all(cases$iso3 %in% h$iso3),!'PSE' %in% v$iso3)
vars<-c('v2x_polyarchy','v2x_libdem','v2x_civlib','v2x_freexp_altinf','v2x_frassoc_thick')
stopifnot(all(vapply(v[vars],function(x)all(x[is.finite(x)]>=0 & x[is.finite(x)]<=1),logical(1))))
stopifnot(all(h$life_evaluation_score>=0 & h$life_evaluation_score<=10))
stopifnot(all(is.na(h$period_start_year[h$period_end_year==2011])))
stopifnot(all(h$period_end_year[h$period_end_year>=2012]-h$period_start_year[h$period_end_year>=2012]==2))
stopifnot(all(is.na(f$score[f$n_available<3])))
# Prove cleaning preserves original V-Dem values for audited keys, not just their range.
e<-new.env();load('data/raw/v16_vdem.RData',envir=e)
key<-paste(e$vdem$country_text_id,e$vdem$year);ids<-match(paste(v$country_text_id,v$year),key)
stopifnot(!anyNA(ids))
for(code in vars)stopifnot(isTRUE(all.equal(v[[code]],e$vdem[[code]][ids],tolerance=1e-12)))
rm(e);gc(verbose=FALSE)
original<-as.data.frame(readxl::read_excel('data/raw/WHR26_Data_Figure_2.1.xlsx'))
ids<-match(paste(h$provider_country,h$period_end_year),paste(original[['Country name']],original$Year))
stopifnot(!anyNA(ids),isTRUE(all.equal(h$life_evaluation_score,original[['Life evaluation (3-year average)']][ids],tolerance=1e-12)))
hp<-read.csv('data/clean/happiness_nonoverlapping_model_panel.csv')
stopifnot(all(hp$predictor_year==hp$period_start_year-1),all(diff(sort(unique(hp$period_end_year)))>=3))
base<-read.csv('data/clean/expanded_country_year_panel.csv')
ids<-match(paste(hp$iso3,hp$predictor_year),paste(base$iso3,base$year))
stopifnot(isTRUE(all.equal(hp$democracy,base$v2x_polyarchy[ids],tolerance=1e-12)))
m<-read.csv('outputs/tables/expanded_model_samples.csv')
stopifnot(all(m$predictor_year[m$outcome!='happiness_life_evaluation']==m$year[m$outcome!='happiness_life_evaluation']-1))
co<-read.csv('outputs/tables/expanded_model_coefficients.csv')
stopifnot(!any(co$outcome=='freedom_descriptive_score' & co$term=='democracy'))
stopifnot(all(co$lower<=co$estimate & co$estimate<=co$upper),all(co$n>=100 & co$economies>=30))
manifest<-read.csv('metadata/additional_source_manifest.csv')
stopifnot(all(unname(tools::md5sum(manifest$file))==manifest$md5))
writeLines(c('PASS: unique audited identifiers; all 11 cases; territorial exclusion;',
 'provider values preserved; valid index ranges; explicit happiness periods;',
 'strict freedom-basket coverage; exact-year annual lags; non-overlapping happiness windows;',
 'predictors precede full survey window; no democracy in freedom-outcome model;',
 'confidence intervals; model sample gates; raw additional-source checksums.'),'outputs/extended_validation.txt')
cat('Extended output checks passed.\n')

if(file.exists('data/clean/historical_income_classifications.csv')) {
 cls<-read.csv('data/clean/historical_income_classifications.csv',na.strings=c('','NA'))
 stopifnot(!anyDuplicated(cls[c('iso3','year')]),all(cls$year==cls$fiscal_year-1),all(cls$gni_data_year==cls$year-1))
 stopifnot(all(is.na(cls$historical_income_group[cls$classification_code=='LM*'])))
 b<-read.csv('outputs/tables/balanced_reference_2000_2024.csv')
 stopifnot(all(b$n_observed==b$n_reference),all(vapply(split(b$n_reference,b$code),function(x)length(unique(x))==1,logical(1))))
 hm<-read.csv('metadata/historical_classification_manifest.csv')
 stopifnot(all(unname(tools::md5sum(hm$file))==hm$md5))
 cat('Historical classification timing, starred exclusions, balanced references and checksum checks passed.\n')
}

if(file.exists('data/clean/historical_income_classifications.csv'))write('PASS: historical classification timing; starred exclusions; balanced-reference counts; historical-source checksum.',file='outputs/extended_validation.txt',append=TRUE)

