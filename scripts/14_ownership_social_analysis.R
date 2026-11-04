source('scripts/text_encoding.R')
.libPaths(c(normalizePath('.R-library'),.libPaths()))
write_csv<-function(x,path)write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')
p<-read.csv('data/clean/expanded_analysis_panel.csv');own<-read.csv('data/clean/state_ownership_control.csv')
gii<-read.csv('data/clean/undp_gender_inequality.csv');imf<-read.csv('data/clean/imf_public_investment.csv')
# Every explanatory variable refers to exactly the preceding calendar/reporting year.
pred<-p[c('iso3','year','v2x_polyarchy','NE.TRD.GNFS.ZS','GOV_WGI_GE.EST','NY.GDP.PCAP.PP.KD','SP.POP.TOTL')]
names(pred)[-(1:2)]<-c('democracy','trade','effectiveness','income','population')
pred<-merge(pred,own[c('iso3','year','ownership_control_0_4','ownership_latent_reversed')],by=c('iso3','year'),all.x=TRUE)
pred<-merge(pred,imf[c('iso3','year','government_investment_pct_gdp')],by=c('iso3','year'),all.x=TRUE)
names(pred)[names(pred)=='ownership_control_0_4']<-'state_control';names(pred)[names(pred)=='ownership_latent_reversed']<-'state_control_latent'
names(pred)[names(pred)=='government_investment_pct_gdp']<-'public_investment'
pred$log_income<-ifelse(pred$income>0,log(pred$income),NA);pred$log_population<-ifelse(pred$population>0,log(pred$population),NA)
pred$predictor_year<-pred$year;pred$year<-pred$year+1L
annual<-merge(p[c('iso3','year','economic_growth','living_available_basket')],gii[c('iso3','year','gender_inequality_index')],by=c('iso3','year'),all.x=TRUE)
annual<-merge(annual,pred,by=c('iso3','year'),all.x=TRUE);annual<-annual[annual$year>=2000 & annual$year<=2024,]
write_csv(annual,'data/clean/ownership_outcome_analysis_panel.csv')
survey<-read.csv('data/clean/pip_national_social_outcomes.csv',na.strings=c('','NA'))
survey<-merge(survey,pred,by=c('iso3','year'),all.x=TRUE)
survey<-survey[survey$year>=2000 & survey$year<=2024,]
write_csv(survey,'data/clean/ownership_survey_analysis_panel.csv')
coefs<-diagnostics<-members<-selections<-vifs<-list()
core<-c('democracy','trade','effectiveness','log_income','log_population')
fit_ownership<-function(d,outcome,model,terms,welfare='Not applicable',block=FALSE) {
 d$y<-d[[outcome]];n_before<-sum(is.finite(d$y));d<-d[complete.cases(d[c('y',terms,'iso3','year')]),]
 if(block) {
  d<-d[!is.na(d$comparability_block) & nzchar(d$comparability_block),]
  n<-tapply(d$year,d$comparability_block,function(x)length(unique(x)))
  d<-d[d$comparability_block %in% names(n)[n>=3],]
 }
 nc<-length(unique(d$iso3));ok<-nrow(d)>=100 && nc>=30
 selections[[length(selections)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,observed_outcome_rows=n_before,
 complete_model_rows=nrow(d),economies=nc,status=if(ok)'Estimated' else 'Withheld: sample gate not reached')
 if(!ok)return(invisible(NULL))
 effects<-c(if(block)'factor(comparability_block)' else 'factor(iso3)','factor(year)')
 fit<-lm(reformulate(c(terms,effects),response='y'),d)
 vc<-sandwich::vcovCL(fit,cluster=d$iso3,type='HC1');ct<-lmtest::coeftest(fit,vcov.=vc,df=nc-1)
 keep<-intersect(terms,rownames(ct));crit<-qt(.975,nc-1)
 coefs[[length(coefs)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,term=keep,estimate=ct[keep,1],cluster_se=ct[keep,2],
 lower=ct[keep,1]-crit*ct[keep,2],upper=ct[keep,1]+crit*ct[keep,2],n=nrow(d),economies=nc,row.names=NULL)
 diagnostics[[length(diagnostics)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,n=nrow(d),economies=nc,
 first_year=min(d$year),last_year=max(d$year),r_squared=summary(fit)$r.squared,breusch_pagan_p=lmtest::bptest(fit)$p.value,
 max_cooks_distance=max(cooks.distance(fit),na.rm=TRUE),predictor_uncertainty='Point predictor estimates; V-Dem measurement uncertainty not propagated')
 members[[length(members)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,iso3=d$iso3,year=d$year,predictor_year=d$predictor_year,
 comparability_block=if(block)d$comparability_block else NA_character_)
 fx<-model.matrix(reformulate(effects),d);rx<-sapply(terms,function(t)lm.fit(fx,d[[t]])$residuals)
 for(t in terms){total<-sum(rx[,t]^2);others<-setdiff(terms,t)
  vif<-if(total<1e-12)NA_real_ else total/sum(lm.fit(cbind(1,rx[,others,drop=FALSE]),rx[,t])$residuals^2)
  vifs[[length(vifs)+1]]<<-data.frame(outcome=outcome,model=model,welfare_type=welfare,term=t,vif=vif,residual_predictor_sd=sd(rx[,t]))
 }
}
for(outcome in c('economic_growth','living_available_basket','gender_inequality_index')) {
 d<-annual[complete.cases(annual[c(outcome,core,'state_control','state_control_latent')]),]
 fit_ownership(d,outcome,'Matched baseline: ownership omitted',core)
 fit_ownership(d,outcome,'Ownership/direct-control specification',c(core,'state_control'))
 fit_ownership(d,outcome,'Latent-scale ownership sensitivity',c(core,'state_control_latent'))
 if(outcome!='gender_inequality_index')fit_ownership(d[d$year<=2019,],outcome,'Ownership and public investment jointly; through 2019',c(core,'state_control','public_investment'))
}
for(w in c('income','consumption'))for(outcome in c('gini_0_100','poverty_3usd_pct'))
 fit_ownership(survey[survey$welfare_type==w,],outcome,'Ownership in comparable-survey blocks',c(core,'state_control'),w,TRUE)
for(item in c('coefs','diagnostics','members','selections','vifs')){
 x<-get(item);if(length(x))write_csv(do.call(rbind,x),paste0('outputs/tables/ownership_model_',item,'.csv'))
}
# Report whether the predictor actually changes, rather than presuming annual identifying variation.
vary<-do.call(rbind,lapply(split(annual[is.finite(annual$state_control),],annual$iso3[is.finite(annual$state_control)]),function(d) {
 d<-d[order(d$year),];data.frame(iso3=d$iso3[1],n_observed=nrow(d),ownership_sd=sd(d$state_control),
 distinct_provider_values=length(unique(d$state_control)),adjacent_year_changes=sum(diff(d$state_control)!=0))
}))
write_csv(vary,'outputs/tables/ownership_within_country_variation.csv')
# Keep original outcome/category definitions intact. New measures are separate dimensions.
status<-read.csv('outputs/tables/five_category_status.csv')
status$unresolved[status$category=='Economic performance']<-'Ownership/direct control and public investment now have separate specifications; broader industrial policy still incomplete'
status$available[status$category=='Social and distributional outcomes']<-'Observed PIP survey measures; SWIID standardized income summaries; UNDP gender inequality; separate local case studies'
status$modeling[status$category=='Social and distributional outcomes']<-'Observed-survey within-block and UNDP gender models available; SWIID draw-based regression withheld by format audit'
status$unresolved[status$category=='Social and distributional outcomes']<-'Provider-modeled summaries are not direct surveys; GII overlaps other domains; no universal social composite'
write_csv(status,'outputs/tables/five_category_status.csv')
cat('Ownership model specifications estimated:',length(diagnostics),'\n')
