source('scripts/text_encoding.R')
.libPaths(c(normalizePath('.R-library'),.libPaths()))
own<-read.csv('data/clean/state_ownership_control.csv');cases<-read.csv('metadata/primary_cases.csv')
e<-new.env();load('data/raw/v16_vdem.RData',e)
idx<-match(paste(own$country_text_id,own$year),paste(e$vdem$country_text_id,e$vdem$year));stopifnot(!anyNA(idx))
stopifnot(!anyDuplicated(own[c('iso3','year')]),all(cases$iso3 %in% own$iso3),!'PSE' %in% own$iso3)
stopifnot(isTRUE(all.equal(own$ownership_control_0_4,4-e$vdem$v2clstown_osp[idx],tolerance=1e-12)))
stopifnot(isTRUE(all.equal(own$ownership_lower_bound,4-e$vdem$v2clstown_osp_codehigh[idx],tolerance=1e-12)))
stopifnot(isTRUE(all.equal(own$ownership_upper_bound,4-e$vdem$v2clstown_osp_codelow[idx],tolerance=1e-12)))
stopifnot(isTRUE(all.equal(own$ownership_latent_reversed,-e$vdem$v2clstown[idx],tolerance=1e-12)))
stopifnot(all(own$ownership_control_0_4>=0 & own$ownership_control_0_4<=4),all(own$ownership_lower_bound<=own$ownership_control_0_4 & own$ownership_control_0_4<=own$ownership_upper_bound))
rm(e);gc(verbose=FALSE)
s<-read.csv('data/clean/swiid_standardized_income_inequality.csv');raw<-read.csv('data/raw/swiid9_92/swiid9_92_summary.csv')
idx<-match(paste(s$country,s$year),paste(raw$country,raw$year));stopifnot(!anyNA(idx),!anyDuplicated(s[c('iso3','year')]))
for(col in c('gini_disp','gini_disp_se','gini_mkt','gini_mkt_se','abs_red','abs_red_se','rel_red','rel_red_se'))stopifnot(isTRUE(all.equal(s[[col]],raw[[col]][idx],tolerance=1e-12)))
stopifnot(all(s$gini_disp>=0 & s$gini_disp<=100),all(s$gini_mkt>=0 & s$gini_mkt<=100))
stopifnot(isTRUE(all.equal(s$disposable_lower95,s$gini_disp-1.96*s$gini_disp_se,tolerance=1e-12)))
c<-read.csv('outputs/tables/swiid_same_year_case_comparison.csv');stopifnot(nrow(c)==11,all(c$year==2016),setequal(c$iso3,cases$iso3))
audit<-read.csv('outputs/tables/swiid_draw_format_audit.csv')
stopifnot(nrow(audit)==4,all(grepl('Withheld',audit$decision)),any(audit$raw_max>100))
u<-read.csv('data/raw/HDR25_Composite_indices_complete_time_series.csv',check.names=FALSE,fileEncoding='latin1')
g<-read.csv('data/clean/undp_gender_inequality.csv')
stopifnot(!anyDuplicated(g[c('iso3','year')]),all(g$year>=1990 & g$year<=2023),all(is.na(g$gender_inequality_index[g$iso3=='HKG'])))
for(y in unique(g$year)) {
 d<-g[g$year==y,];expected<-u[[paste0('gii_',y)]][match(d$iso3,u$iso3)]
 stopifnot(isTRUE(all.equal(d$gender_inequality_index,expected,tolerance=1e-12)))
 z<-d$gender_relative_z[is.finite(d$gender_relative_z)]
 if(length(z))stopifnot(length(z)>=100,abs(mean(z))<1e-8,abs(sd(z)-1)<1e-8)
}
stopifnot(all(validUTF8(g$provider_country)))
m<-read.csv('outputs/tables/ownership_model_members.csv',na.strings=c('','NA'))
stopifnot(all(m$predictor_year==m$year-1),!any(m$outcome %in% c('gini_disp','gini_mkt')))
stopifnot(!any(m$iso3=='HKG' & m$outcome=='gender_inequality_index'))
for(outcome in c('economic_growth','living_available_basket','gender_inequality_index')) {
 a<-m[m$outcome==outcome & m$model=='Matched baseline: ownership omitted',]
 b<-m[m$outcome==outcome & m$model=='Ownership/direct-control specification',]
 stopifnot(identical(sort(paste(a$iso3,a$year)),sort(paste(b$iso3,b$year))))
}
panel<-read.csv('data/clean/ownership_outcome_analysis_panel.csv')
idx<-match(paste(panel$iso3,panel$predictor_year),paste(own$iso3,own$year))
stopifnot(isTRUE(all.equal(panel$state_control,own$ownership_control_0_4[idx],tolerance=1e-12)))
co<-read.csv('outputs/tables/ownership_model_coefs.csv');stopifnot(all(co$n>=100 & co$economies>=30),all(co$lower<=co$estimate & co$estimate<=co$upper))
manifest<-read.csv('metadata/ownership_social_source_manifest.csv');stopifnot(all(unname(tools::md5sum(manifest$file))==manifest$md5))
stopifnot(unname(tools::md5sum('data/raw/swiid9_92.zip'))=='29fea15aa2dc73d757cf1775cf99e9c0')
writeLines(c('PASS: original V-Dem values and correct score/bound reversal; source identity exclusions;',
 'SWIID published summary values preserved; uncertainty bands; same 2016 comparison for all 11 cases;',
 'SWIID unresolved draw formats explicitly withheld from regression; no guessed correction;',
 'UNDP source values, rank/aggregate exclusion, Latin-1 decoding, missing Hong Kong and annual score gates;',
 'exact predictor-year joins; identical baseline/ownership samples; sample gates; intervals; source/archive checksums.'),
 'outputs/better_measure_validation.txt')
cat('Better-measure source and analysis checks passed.\n')
