source('scripts/text_encoding.R')
# Expanded, exploratory analysis. No state-intervention proxy is invented.
.libPaths(c(normalizePath('.R-library'),.libPaths()))
write_csv<-function(x,p)write.csv(x,p,row.names=FALSE,na='',fileEncoding='UTF-8')
p<-read.csv('data/clean/expanded_country_year_panel.csv')
scores<-read.csv('data/clean/category_scores.csv')
freedom<-read.csv('data/clean/freedom_category_scores.csv')
happy<-read.csv('data/clean/happiness_period_scores.csv')
countries<-read.csv('metadata/countries.csv');cases<-read.csv('metadata/primary_cases.csv')
z<-read.csv('data/clean/standardized_indicators.csv')
living<-scores[scores$category=='living',c('iso3','year','score')];names(living)[3]<-'living_available_basket'
p<-merge(p,living,by=c('iso3','year'),all.x=TRUE)
f<-freedom[c('iso3','year','score')];names(f)[3]<-'freedom_descriptive_score'
p<-merge(p,f,by=c('iso3','year'),all.x=TRUE)
# Stable living basket checks the influence of changing education coverage.
fixed_codes<-c('SP.DYN.LE00.IN','SP.DYN.IMRT.IN','EG.ELC.ACCS.ZS')
zfixed<-z[z$code %in% fixed_codes,c('iso3','year','code','z')]
fixed<-do.call(rbind,lapply(split(zfixed,interaction(zfixed$iso3,zfixed$year,drop=TRUE)),function(d)
 data.frame(iso3=d$iso3[1],year=d$year[1],living_fixed_basket=if(sum(is.finite(d$z))==3)mean(d$z) else NA)))
p<-merge(p,fixed,by=c('iso3','year'),all.x=TRUE)
p$economic_growth<-p[['NY.GDP.PCAP.KD.ZG']]
write_csv(p,'data/clean/expanded_analysis_panel.csv')
lag<-p[c('iso3','year','v2x_polyarchy','NE.TRD.GNFS.ZS','GOV_WGI_GE.EST','NY.GDP.PCAP.PP.KD','SP.POP.TOTL','TM.TAX.MRCH.WM.AR.ZS')]
names(lag)[-(1:2)]<-c('democracy','trade','effectiveness','income','population','tariff')
lag$log_income<-ifelse(lag$income>0,log(lag$income),NA)
lag$log_population<-ifelse(lag$population>0,log(lag$population),NA)
# Common annual predictors use exactly t-1. Happiness predictors precede the whole survey window.
lag$predictor_year<-lag$year;lag$year<-lag$year+1L
annual<-merge(p[c('iso3','year','economic_growth','living_available_basket','living_fixed_basket','freedom_descriptive_score')],lag,by=c('iso3','year'),all.x=TRUE)
annual<-annual[annual$year>=2000 & annual$year<=2024,]
ht<-happy[happy$period_end_year %in% seq(max(happy$period_end_year),2012,by=-3),]
ht$year<-ht$period_end_year;ht$predictor_year<-ht$period_start_year-1L
lh<-lag;lh$year<-NULL
hp<-merge(ht,lh,by=c('iso3','predictor_year'),all.x=TRUE)
hp$happiness_life_evaluation<-hp$life_evaluation_score
write_csv(hp,'data/clean/happiness_nonoverlapping_model_panel.csv')
coefficients<-diagnostics<-samples<-selections<-vifs<-list()
fit_one<-function(d,outcome,variant,omit_democracy=FALSE) {
  terms<-c(if(!omit_democracy)'democracy',if(variant=='tariffs_instead_of_trade')'tariff' else 'trade','effectiveness',
           if(variant!='without_income_control')'log_income','log_population')
  if(variant=='exclude_singapore_hong_kong')d<-d[!d$iso3 %in% c('SGP','HKG'),]
  d$y<-d[[outcome]];n_outcome<-sum(is.finite(d$y))
  good<-complete.cases(d[c('y',terms,'iso3','year')]);d<-d[good,]
  n_countries<-length(unique(d$iso3))
  selections[[length(selections)+1]]<<-data.frame(outcome=outcome,variant=variant,observed_outcome_rows=n_outcome,
    complete_model_rows=nrow(d),economies=n_countries,status=if(nrow(d)>=100 && n_countries>=30)'Estimated' else 'Insufficient sample')
  if(nrow(d)<100 || n_countries<30)return(invisible(NULL))
  effects<-c('factor(year)',if(variant!='year_effects_only')'factor(iso3)')
  fit<-lm(reformulate(c(terms,effects),response='y'),d)
  ct<-lmtest::coeftest(fit,vcov.=sandwich::vcovCL(fit,cluster=d$iso3,type='HC1'),df=n_countries-1)
  keep<-intersect(terms,rownames(ct));crit<-qt(.975,n_countries-1)
  coefficients[[length(coefficients)+1]]<<-data.frame(outcome=outcome,variant=variant,term=keep,
   estimate=ct[keep,1],cluster_se=ct[keep,2],lower=ct[keep,1]-crit*ct[keep,2],upper=ct[keep,1]+crit*ct[keep,2],
   n=nrow(d),economies=n_countries,row.names=NULL)
  diagnostics[[length(diagnostics)+1]]<<-data.frame(outcome=outcome,variant=variant,n=nrow(d),economies=n_countries,
   first_year=min(d$year),last_year=max(d$year),r_squared=summary(fit)$r.squared,
   breusch_pagan_p=lmtest::bptest(fit)$p.value,max_cooks_distance=max(cooks.distance(fit),na.rm=TRUE),
   predictor_timing=if(outcome=='happiness_life_evaluation')'Before the entire survey window' else 'Exactly previous calendar year')
  samples[[length(samples)+1]]<<-data.frame(outcome=outcome,variant=variant,iso3=d$iso3,year=d$year,predictor_year=d$predictor_year)
  # VIFs calculated after removing the same fixed effects used in each specification.
  fx<-model.matrix(reformulate(effects),d)
  residual_x<-sapply(terms,function(t)lm.fit(fx,d[[t]])$residuals)
  for(t in terms) {
   total<-sum(residual_x[,t]^2);others<-setdiff(terms,t)
   if(total<1e-12) {vif<-NA_real_;note<-'Essentially no remaining variation; effect is not identified'} else {
    err<-lm.fit(cbind(1,residual_x[,others,drop=FALSE]),residual_x[,t])$residuals
    ratio<-sum(err^2)/total;vif<-if(ratio<=0)Inf else 1/ratio;note<-'After removing model fixed effects'
   }
   vifs[[length(vifs)+1]]<<-data.frame(outcome=outcome,variant=variant,term=t,vif=vif,
      residual_predictor_sd=sd(residual_x[,t]),note=note)
  }
}
for(outcome in c('economic_growth','living_available_basket','living_fixed_basket'))
 for(variant in c('year_effects_only','country_year_effects','without_income_control','tariffs_instead_of_trade','exclude_singapore_hong_kong'))
  fit_one(annual,outcome,variant)
# Freedom basket shares V-Dem components with democracy. This model deliberately omits democracy.
fit_one(annual,'freedom_descriptive_score','country_year_effects',omit_democracy=TRUE)
for(variant in c('year_effects_only','country_year_effects','without_income_control'))fit_one(hp,'happiness_life_evaluation',variant)
for(item in c('coefficients','diagnostics','samples','selections','vifs')) {
 x<-get(item);if(length(x))write_csv(do.call(rbind,x),paste0('outputs/tables/expanded_model_',item,'.csv'))
}
# Calendar-year comparisons: report observations, never replace with a different year's latest value.
calendar<-p[p$iso3 %in% cases$iso3 & p$year %in% c(1990,2000,2010,2020,2024),]
write_csv(calendar,'outputs/tables/calendar_year_case_comparisons.csv')
# Exploratory development-stage alignment, anchored to Singapore income in 2000.
base_income<-p[p$iso3=='SGP' & p$year==2000,'NY.GDP.PCAP.PP.KD']
stopifnot(length(base_income)==1,is.finite(base_income))
stage<-list()
for(iso in cases$iso3) {
 d<-p[p$iso3==iso,];d<-d[order(d$year),];income<-d[['NY.GDP.PCAP.PP.KD']]
 good<-which(is.finite(income));qualifying<-integer()
 for(i in head(good,-2))if(i+2<=nrow(d) && all(d$year[i:(i+2)]==d$year[i]+0:2) &&
   all(is.finite(income[i:(i+2)])) && all(income[i:(i+2)]>=base_income) && income[i]<=1.1*base_income)qualifying<-c(qualifying,i)
 found<-length(qualifying)>0;i<-if(found)qualifying[1] else NA_integer_
 stage[[length(stage)+1]]<-data.frame(iso3=iso,benchmark='Singapore PPP GDP per capita in 2000',benchmark_income=base_income,
 match_year=if(found)d$year[i] else NA,matched_income=if(found)income[i] else NA,
 life_expectancy=if(found)d[['SP.DYN.LE00.IN']][i] else NA,
 stage_status=if(!found)'No qualifying observed window' else if(i==min(good))'Earliest observed income already qualifies; crossing is left-censored' else 'First observed qualifying sustained 3-year window',
 rule='Income at least benchmark, no more than 10% above in first year, and at least benchmark for next 2 years')
}
write_csv(do.call(rbind,stage),'outputs/tables/development_stage_comparison.csv')
# Transparent status for all five requested outcome areas.
status<-data.frame(category=c('Economic performance','Living standards','Happiness and well-being','Freedom and governance','Social and distributional outcomes'),
 available=c('Two-indicator provisional score; growth as separate model outcome',
 'Four-indicator provisional score; fixed three-indicator sensitivity',
 'Observed multi-year life-evaluation scores and provider uncertainty; not annual data',
 'Three-index provisional descriptive score from V-Dem; all three required',
 'Gini, poverty and labor-force participation remain separate observed measures'),
 modeling=c('Exploratory growth models include democracy, trade, effectiveness and controls',
 'Expanded association models and basket/control/openness sensitivity',
 'Models use non-overlapping survey windows and predictors before each window',
 'Democracy omitted from freedom-outcome model because components overlap',
 'Pooled regression withheld pending survey concept comparability review'),
 unresolved=c('State intervention unmeasured; growth is not the economic composite',
 'Health overlap and changing education coverage',
 'Annual Gallup series unavailable in the verified public download; one primary measure, not a composite',
 'Not an independent test of democracy effects; expert-coded uncertainty',
 'Sparse coverage; income versus consumption and household survey definitions'))
write_csv(status,'outputs/tables/five_category_status.csv')
cat('Expanded model specifications estimated:',length(diagnostics),'\n')

