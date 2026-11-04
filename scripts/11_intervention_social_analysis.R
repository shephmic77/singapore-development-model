source('scripts/text_encoding.R')
.libPaths(c(normalizePath('.R-library'),.libPaths()))
write_csv<-function(x,path)write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')
p<-read.csv('data/clean/expanded_analysis_panel.csv')
imf<-read.csv('data/clean/imf_public_investment.csv');pip<-read.csv('data/clean/pip_national_social_outcomes.csv',na.strings=c('','NA'))
# Same-source public investment is joined to the predictor year, not contemporaneous outcome year.
predictors<-p[c('iso3','year','v2x_polyarchy','NE.TRD.GNFS.ZS','GOV_WGI_GE.EST','NY.GDP.PCAP.PP.KD','SP.POP.TOTL')]
names(predictors)[-(1:2)]<-c('democracy','trade','effectiveness','income','population')
predictors<-merge(predictors,imf[c('iso3','year','government_investment_pct_gdp')],by=c('iso3','year'),all.x=TRUE)
names(predictors)[names(predictors)=='government_investment_pct_gdp']<-'public_investment'
predictors$log_income<-ifelse(predictors$income>0,log(predictors$income),NA)
predictors$log_population<-ifelse(predictors$population>0,log(predictors$population),NA)
predictors$predictor_year<-predictors$year;predictors$year<-predictors$year+1L
annual<-merge(p[c('iso3','year','economic_growth','living_available_basket')],predictors,by=c('iso3','year'),all.x=TRUE)
write_csv(annual,'data/clean/public_investment_analysis_panel.csv')
social<-merge(pip,predictors,by=c('iso3','year'),all.x=TRUE)
write_csv(social,'data/clean/social_survey_analysis_panel.csv')
coefs<-diagnostics<-membership<-selections<-vifs<-list()
core<-c('democracy','trade','effectiveness','log_income','log_population')
keep_comparable_blocks<-function(d) {
 d<-d[!is.na(d$comparability_block) & nzchar(d$comparability_block),]
 counts<-tapply(d$year,d$comparability_block,function(x)length(unique(x)))
 d[d$comparability_block %in% names(counts)[counts>=3],]
}
fit_topic<-function(d,outcome,model,terms,scope,welfare='Not applicable',block=FALSE) {
 d$y<-d[[outcome]];before<-sum(is.finite(d$y));d<-d[complete.cases(d[c('y',terms,'iso3','year')]),]
 if(block)d<-keep_comparable_blocks(d)
 nc<-length(unique(d$iso3));ok<-nrow(d)>=100 && nc>=30
 selections[[length(selections)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,sample_definition=scope,
 observed_outcome_rows=before,complete_model_rows=nrow(d),economies=nc,
 comparability_blocks=if(block)length(unique(d$comparability_block)) else NA_integer_,status=if(ok)'Estimated' else 'Not estimated: minimum 100 observations and 30 economies not reached')
 if(!ok)return(invisible(NULL))
 effects<-c(if(block)'factor(comparability_block)' else 'factor(iso3)','factor(year)')
 fit<-lm(reformulate(c(terms,effects),response='y'),d)
 ct<-lmtest::coeftest(fit,vcov.=sandwich::vcovCL(fit,cluster=d$iso3,type='HC1'),df=nc-1)
 rows<-intersect(terms,rownames(ct));crit<-qt(.975,nc-1)
 coefs[[length(coefs)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,term=rows,
 estimate=ct[rows,1],cluster_se=ct[rows,2],lower=ct[rows,1]-crit*ct[rows,2],upper=ct[rows,1]+crit*ct[rows,2],n=nrow(d),economies=nc,row.names=NULL)
 diagnostics[[length(diagnostics)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,n=nrow(d),economies=nc,
 first_year=min(d$year),last_year=max(d$year),r_squared=summary(fit)$r.squared,
 breusch_pagan_p=lmtest::bptest(fit)$p.value,max_cooks_distance=max(cooks.distance(fit),na.rm=TRUE),
 fixed_effects=if(block)'Within-country comparable-survey spell and reporting year' else 'Country and calendar year',
 interpretation=if(block)'Within-spell survey associations; income and consumption estimated separately' else 'Narrow public-capital-formation association, not total intervention')
 m<-data.frame(outcome=outcome,model=model,welfare_type=welfare,iso3=d$iso3,year=d$year,predictor_year=d$predictor_year)
 m$comparability_block<-if(block)d$comparability_block else NA_character_
 membership[[length(membership)+1]]<<-m
 fx<-model.matrix(reformulate(effects),d);rx<-sapply(terms,function(t)lm.fit(fx,d[[t]])$residuals)
 for(t in terms) {
 total<-sum(rx[,t]^2);others<-setdiff(terms,t)
 vif<-if(total<1e-12)NA_real_ else {err<-lm.fit(cbind(1,rx[,others,drop=FALSE]),rx[,t])$residuals;total/sum(err^2)}
 vifs[[length(vifs)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,term=t,vif=vif,residual_predictor_sd=sd(rx[,t]))
 }
}
# IMF ends in 2019. Main models end in 2019, with 2020 included only as a labeled sensitivity.
for(outcome in c('economic_growth','living_available_basket')) {
 d<-annual[annual$year>=2000 & annual$year<=2019,]
 common<-d[complete.cases(d[c(outcome,core,'public_investment')]),]
 fit_topic(common,outcome,'Matched sample: without public investment',core,'Annual outcomes 2000-2019; same rows in the paired models')
 fit_topic(common,outcome,'Matched sample: with public investment',c(core,'public_investment'),'Annual outcomes 2000-2019; same rows in the paired models')
 fit_topic(common,outcome,'Sensitivity: income control omitted',c(setdiff(core,'log_income'),'public_investment'),'Annual outcomes 2000-2019; main matched sample')
 covid<-annual[annual$year>=2000 & annual$year<=2020,]
 fit_topic(covid,outcome,'Sensitivity: include 2020 outcome',c(core,'public_investment'),'Annual outcomes through 2020; no post-2019 investment observations assumed')
}
# No mixing welfare concepts, urban samples, or disconnected survey comparability spells.
for(welfare in c('income','consumption'))for(outcome in c('gini_0_100','poverty_3usd_pct')) {
 d<-social[social$welfare_type==welfare & social$year>=2000 & social$year<=2024,]
 fit_topic(d,outcome,'Survey model: no public-investment term',core,'National survey labels; 2000-2024; at least 3 observed years per comparability block',welfare,TRUE)
 d<-d[d$year<=2019,];common<-d[complete.cases(d[c(outcome,core,'public_investment')]),];common<-keep_comparable_blocks(common)
 fit_topic(common,outcome,'Matched sample: without public investment',core,'National survey labels; 2000-2019; paired complete sample',welfare,TRUE)
 fit_topic(common,outcome,'Matched sample: with public investment',c(core,'public_investment'),'National survey labels; 2000-2019; paired complete sample',welfare,TRUE)
}
for(item in c('coefs','diagnostics','membership','selections','vifs')) {
 d<-get(item);if(length(d))write_csv(do.call(rbind,d),paste0('outputs/tables/fiscal_social_model_',item,'.csv'))
}
# Preserve the previous study and update only the current summary of the social area.
status<-read.csv('outputs/tables/five_category_status.csv')
i<-which(status$category=='Social and distributional outcomes')
status$available[i]<-'PIP poverty, inequality and distribution shares with welfare/coverage labels; separate official Singapore Gini definitions'
status$modeling[i]<-'Income and consumption modeled separately within provider comparability spells when sample gates pass; no social composite'
status$unresolved[i]<-'Singapore/Hong Kong absent from PIP; Argentina urban-only; local definitions are not silently pooled; no universally comparable social score'
status$unresolved[1]<-'Public investment added only as a narrow, separately labeled extension; broader state intervention remains unmeasured'
write_csv(status,'outputs/tables/five_category_status.csv')
cat('Fiscal/social model attempts:',length(selections),'; estimated:',length(diagnostics),'\n')
