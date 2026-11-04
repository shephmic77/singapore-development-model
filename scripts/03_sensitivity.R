source('scripts/text_encoding.R')
# Additional benchmark sensitivity. Run after the main pipeline.
p<-read.csv('data/clean/standardized_indicators.csv')
countries<-read.csv('metadata/countries.csv')
write_csv<-function(x,path)write.csv(x,path,row.names=FALSE,na='')
# Fixed baseline: same 2010 mean and SD applied to all years.
base<-p[p$year==2010,]
base<-do.call(rbind,lapply(split(base,base$code),function(d) {
 x<-d$transformed[is.finite(d$transformed)]
 data.frame(code=d$code[1],baseline_year=2010,n=length(x),mean=mean(x),sd=sd(x))
}))
catalog<-read.csv('metadata/indicators.csv')
d<-merge(p,base,by='code');d<-merge(d,catalog[c('code','direction')],by='code')
d$fixed_2010_z<-ifelse(d$n>=100 & d$sd>0 & d$direction!=0,d$direction*(d$transformed-d$mean)/d$sd,NA)
write_csv(d[c('iso3','year','code','value','z','fixed_2010_z','baseline_year','n')], 'data/clean/fixed_baseline_sensitivity.csv')
# Today's membership across historical years is labeled explicitly; never call it historical high income.
high<-p[p$current_income_group=='High income',]
refs<-do.call(rbind,lapply(split(high,interaction(high$code,high$year,drop=TRUE)),function(d) {
 x<-d$value[is.finite(d$value)]
 data.frame(code=d$code[1],year=d$year[1],group='current high-income membership',n=length(x),
 mean=if(length(x))mean(x) else NA,sd=sd(x))
}))
write_csv(refs,'outputs/tables/current_high_income_reference.csv')
# Readable missingness summary uses the full collection denominator.
cv<-read.csv('outputs/tables/coverage_by_year.csv')
recent<-cv[cv$year>=2000,]
summary<-aggregate(cbind(n_observed,missing_share)~code,recent,mean)
write_csv(summary,'outputs/tables/modern_coverage_summary.csv')
lines<-c('# Data quality report','','## Scope',
 paste('Reference population:',nrow(countries),'nonaggregate World Bank economies.'),
 'Coverage is assessed separately for every indicator and year; modern summary covers 2000-2025.',
 'Null values are retained, not set to zero. Observed does not mean independently verified or directly measured.',
 '', '## Average observed economies per year, 2000-2025',
 '| Indicator | Mean observed economies | Mean missing share |','| --- | ---: | ---: |')
for(i in seq_len(nrow(summary))) lines<-c(lines,sprintf('| %s | %.1f | %.1f%% |',summary$code[i],summary$n_observed[i],100*summary$missing_share[i]))
lines<-c(lines,'','## Interpretation',
 'Missingness differs across years and indicators. Annual reference composition and category basket changes can shift scores.',
 'Source definitions may include modeled estimates, survey differences and methodological changes. Gini and poverty observations are not automatically comparable.',
 'Use case_missingness.csv for the 11 selected cases over the entire 1965-2025 requested grid.',
 'Fixed-2010 scores hold the statistical anchor constant but do not hold the observed population constant. They are a sensitivity analysis, not a causal benchmark.',
 'Current-income-group means use current membership and cannot show historical high-income peer performance.',
 'Charts and coefficients should be read alongside sample counts, source metadata and model limitations.')
writeLines(lines,'outputs/data_quality_report.md')

# Refresh the labeled outputs after generating analysis data.
if(!isTRUE(getOption('soda.defer_reader_outputs',FALSE))) source('scripts/05_reader_outputs.R')


