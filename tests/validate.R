source('scripts/text_encoding.R')
# Actual-output checks: run after scripts/01_pipeline.R from the root.
p <- read.csv('data/clean/international_long.csv')
s <- read.csv('data/clean/standardized_indicators.csv')
r <- read.csv('outputs/tables/global_reference.csv')
c <- read.csv('data/clean/category_scores.csv')
cases <- read.csv('metadata/primary_cases.csv')
stopifnot(nrow(p)>0,!anyDuplicated(p[c('iso3','year','code')]))
stopifnot(length(unique(cases$iso3))==11,all(cases$iso3 %in% p$iso3),'HKG' %in% p$iso3)
stopifnot(!any(c('WLD','HIC','EAS') %in% p$iso3))
stopifnot(all(p$year>=1965 & p$year<=2025))
stopifnot(all(is.na(c$score[c$n_available<c$minimum])))
stopifnot(all(c$category %in% c('economic','living')))
for(d in split(s[is.finite(s$z),],interaction(s$code[is.finite(s$z)],s$year[is.finite(s$z)],drop=TRUE))) {
  stopifnot(nrow(d)>=100,abs(mean(d$z))<1e-8,abs(sd(d$z)-1)<1e-8)
}
stopifnot(all(s$percentile[is.finite(s$percentile)]>=0),all(s$percentile[is.finite(s$percentile)]<=100))
# Mortality ordering must reverse. Verify using actual transformed values.
d<-s[s$code=='SP.DYN.IMRT.IN' & is.finite(s$z),]
if(nrow(d)) { d<-d[d$year==max(d$year),];stopifnot(cor(d$transformed,d$z)< -0.999) }
.libPaths(c(normalizePath('.R-library'),.libPaths()))
manifest<-read.csv('data/raw/manifest.csv')
stopifnot(all(unname(tools::md5sum(manifest$file))==manifest$md5))
if(file.exists('data/clean/living_model_sample.csv')) {
  m<-read.csv('data/clean/living_model_sample.csv')
  lookup<-p[p$code=='NE.TRD.GNFS.ZS',c('iso3','year','value')];lookup$year<-lookup$year+1
  check<-merge(m,lookup,by=c('iso3','year'))
  stopifnot(all(abs(check$lag_trade-check$value)<1e-8))
}
writeLines(c('PASS: unique country-year-indicator keys; all 11 cases including Hong Kong;',
 'aggregate exclusion; year bounds; category coverage gates; annual z-score moments;',
 'percentile bounds; reversed mortality direction; raw file checksums; exact-year lags.'),
 'outputs/validation.txt')
cat('All output checks passed.\n')

