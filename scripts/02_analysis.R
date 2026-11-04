# Exploratory outputs use only observed data. Reduced models omit unavailable constructs.
plot_file <- function(name, expr, width=1100, height=750) {
  png(file.path('outputs/figures', name), width=width,height=height,res=130)
  tryCatch(force(expr),finally=dev.off())
}
coverage_matrix <- xtabs(n_observed~code+year,coverage)
plot_file('coverage.png', {
  par(mar=c(5,12,3,2)); image(as.numeric(colnames(coverage_matrix)),seq_len(nrow(coverage_matrix)),
    t(coverage_matrix),axes=FALSE,xlab='Year',ylab='',col=hcl.colors(30,'YlGnBu'),main='Observed economies per indicator and year')
  axis(1); axis(2,seq_len(nrow(coverage_matrix)),rownames(coverage_matrix),las=2,cex.axis=.65); mtext('Dark purple = 0; pale yellow = 217 economies',side=3,line=.2,cex=.7)
})
plot_file('singapore_life_expectancy.png', {
  d<-panel[panel$code=='SP.DYN.LE00.IN' & panel$iso3=='SGP',]; d<-d[order(d$year),]
  g<-aggregate(value~year,panel[panel$code=='SP.DYN.LE00.IN',],mean)
  plot(d$year,d$value,type='l',lwd=2,col='darkred',xlab='Year',ylab='Life expectancy (years)',
       ylim=range(c(d$value,g$value),na.rm=TRUE),main='Singapore and available-economy mean')
  lines(g$year,g$value,lty=2); legend('bottomright',c('Singapore','Unweighted reference mean'),col=c('darkred','black'),lty=c(1,2),bty='n')
})
plot_file('primary_case_category_trends.png', {
  par(mfrow=c(2,1),mar=c(3,4,5,1)); palette <- hcl.colors(11,'Dark 3')
  for(cat in c('economic','living')) {
    d<-scores[scores$category==cat & scores$iso3 %in% cases$iso3,]
    plot(NA,xlim=c(1990,END),ylim=range(d$score,na.rm=TRUE),xlab='Year',ylab='Annual reference z-score',main=paste(cat,'pilot basket'))
    for(i in seq_len(nrow(cases))) {s<-d[d$iso3==cases$iso3[i],];s<-s[order(s$year),];lines(s$year,s$score,col=palette[i],lty=1+(i>8))}
    legend('topleft',inset=c(0,-.24),xpd=NA,cases$iso3,col=palette,lty=1+(seq_len(nrow(cases))>8),ncol=6,cex=.65,bty='n')
  }
})
# Explicit same-year case table. Do not substitute different countries' latest years.
recent <- scores[scores$year>=2015 & scores$iso3 %in% cases$iso3,]
counts <- aggregate(is.finite(score)~year+category,recent,sum)
write_csv(counts,'outputs/tables/primary_case_score_coverage.csv')
write_csv(recent,'outputs/tables/primary_case_recent_scores.csv')
# Correlations use modern years. Report pairwise n separately.
vars<-intersect(c('NY.GDP.PCAP.PP.KD','SP.DYN.LE00.IN','NE.TRD.GNFS.ZS','GOV_WGI_GE.EST','SI.POV.GINI'),names(wide))
x<-wide[wide$year>=2000,vars,drop=FALSE]
write_csv(data.frame(variable=vars,cor(x,use='pairwise.complete.obs')), 'outputs/tables/correlations.csv')
write_csv(data.frame(variable=vars,crossprod(!is.na(as.matrix(x)))), 'outputs/tables/correlation_sample_sizes.csv')
# Lag predictors using an exact preceding year, never a preceding nonmissing row.
lagvars<-c('NY.GDP.PCAP.PP.KD','NE.TRD.GNFS.ZS','GOV_WGI_GE.EST','SP.POP.TOTL')
coefs<-list(); diagnostics<-list(); model_notes<-character()
if(all(lagvars %in% names(wide))) {
  lag<-wide[c('iso3','year',lagvars)];lag$year<-lag$year+1L
  names(lag)[-(1:2)]<-c('lag_income','lag_trade','lag_effectiveness','lag_population')
  m<-merge(scores[scores$category=='living',],lag,by=c('iso3','year'))
  m<-m[m$year>=2000 & m$lag_income>0 & m$lag_population>0,]
  m<-m[complete.cases(m[c('score','lag_income','lag_trade','lag_effectiveness','lag_population')]),]
  write_csv(m,'data/clean/living_model_sample.csv')
  if(nrow(m)>100 && length(unique(m$iso3))>=30) {
    for(kind in c('pooled_year_FE','country_year_FE')) {
      formula<-if(kind=='pooled_year_FE') score~lag_trade+lag_effectiveness+log(lag_income)+log(lag_population)+factor(year) else score~lag_trade+lag_effectiveness+log(lag_income)+log(lag_population)+factor(year)+factor(iso3)
      fit<-lm(formula,m)
      vc<-sandwich::vcovCL(fit,cluster=m$iso3,type='HC1')
      ct<-lmtest::coeftest(fit,vcov.=vc,df=length(unique(m$iso3))-1)
      keep<-!grepl('factor',rownames(ct)); crit<-qt(.975,length(unique(m$iso3))-1)
      coefs[[kind]]<-data.frame(model=kind,term=rownames(ct)[keep],estimate=ct[keep,1],
        cluster_se=ct[keep,2],lower=ct[keep,1]-crit*ct[keep,2],upper=ct[keep,1]+crit*ct[keep,2],
        n=nobs(fit),economies=length(unique(m$iso3)),row.names=NULL)
      diagnostics[[kind]]<-data.frame(model=kind,n=nobs(fit),economies=length(unique(m$iso3)),
        r_squared=summary(fit)$r.squared,condition_number=kappa(model.matrix(fit)),
        breusch_pagan_p=lmtest::bptest(fit)$p.value,max_cooks_distance=max(cooks.distance(fit),na.rm=TRUE))
      saveRDS(fit,file.path('outputs',paste0(kind,'.rds')))
    }
    write_csv(do.call(rbind,coefs),'outputs/tables/reduced_model_coefficients.csv')
    write_csv(do.call(rbind,diagnostics),'outputs/tables/model_diagnostics.csv')
    within_sd<-sapply(c('lag_trade','lag_effectiveness','lag_income','lag_population'),function(v)
      sd(m[[v]]-ave(m[[v]],m$iso3,FUN=mean)))
    write_csv(data.frame(variable=names(within_sd),within_sd=within_sd),'outputs/tables/within_country_variation.csv')
  } else model_notes<-'Insufficient complete observations for reduced model.'
}
observed<-panel[is.finite(panel$value),]
status<-c('# World Bank foundation run: see CURRENT_RESULTS.html for the expanded current study', '',paste('Run date:',Sys.Date()),
 paste('Observed indicator values:',nrow(observed)),paste('Reference economies:',nrow(countries)),
 paste('Indicators with observations:',length(unique(observed$code))),
 paste('Primary cases with observations:',sum(cases$iso3 %in% observed$iso3)),
 '', '## What these outputs support',
 'Descriptive country-year comparisons and two provisional category baskets. Annual scores describe relative position, not absolute progress.',
 'Reduced living-standard associations can be explored using lagged trade share, government effectiveness, income and population. These do not test the full Singapore model.',
 '', '## Missing research components',
 'V-Dem democracy and civil liberties, annual happiness, and a defensible intervention measure are not collected in this initial run.',
 'Three category composites are withheld. Social measures remain separate because comparability and direction need further review.',
 'No causal claim, transferability conclusion, single overall ranking, or full four-variable regression is supported.',
 '', '## Reading the models',
 'Country-clustered confidence intervals allow within-country dependence. Year effects absorb common calendar shocks; country effects absorb time-invariant differences.',
 'Country clustering does not solve cross-country dependence, endogeneity, selective missingness or measurement error. Income can be a mediator, so controls alter the question.',
 'Condition numbers, heteroskedasticity checks and influence summaries are diagnostics, not certification. Covariate and sample robustness remain necessary.',
 '', '## Preliminary descriptive finding')
s<-observed[observed$iso3=='SGP' & observed$code=='SP.DYN.LE00.IN',];s<-s[order(s$year),]
if(nrow(s)>1) status<-c(status,sprintf('The retrieved World Bank series reports Singapore life expectancy of %.2f years in %d and %.2f in %d. This is a descriptive change, not an institutional effect.',s$value[1],s$year[1],tail(s$value,1),tail(s$year,1)))
writeLines(c(status,model_notes),'outputs/research_status.md')




