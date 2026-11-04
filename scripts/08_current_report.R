source('scripts/text_encoding.R')
# Current, plain-language report and additional charts. No new downloads or model fitting.
write_csv<-function(x,p)write.csv(x,p,row.names=FALSE,na='',fileEncoding='UTF-8')
cases<-read.csv('metadata/primary_cases.csv');countries<-read.csv('metadata/countries.csv')
h<-read.csv('data/clean/happiness_period_scores.csv');v<-read.csv('data/clean/vdem_country_year.csv')
f<-read.csv('data/clean/freedom_category_scores.csv');s<-read.csv('data/clean/category_scores.csv')
status<-read.csv('outputs/tables/five_category_status.csv');coef<-read.csv('outputs/tables/expanded_model_coefficients.csv')
plot_png<-function(name,expr,width=1500,height=1000) {
 png(file.path('outputs/figures',name),width=width,height=height,res=140)
 tryCatch(force(expr),finally=dev.off())
}
latest<-max(h$period_end_year);hl<-h[h$period_end_year==latest & h$primary_case,]
hl<-hl[match(cases$iso3,hl$iso3),];hl$name<-cases$name
plot_png('happiness_latest_period.png',{
 par(mar=c(6,11,5,2),oma=c(3,0,0,0));y<-rev(seq_len(nrow(hl)))
 plot(hl$life_evaluation_score,y,xlim=c(0,10),ylim=c(.5,nrow(hl)+.5),yaxt='n',pch=19,col='#176B8A',
 xlab='Average reported life evaluation (0 = worst possible life; 10 = best possible life)',ylab='',
 main=paste0('Life evaluation in ',latest-2,'-',latest,': the 11 selected cases'))
 axis(2,y,cases$name,las=2,cex.axis=.9)
 good<-complete.cases(hl[c('life_evaluation_score','lower_95','upper_95')])
 arrows(hl$lower_95[good],y[good],hl$upper_95[good],y[good],angle=90,code=3,length=.06)
 abline(v=h$reference_mean[h$period_end_year==latest][1],col='gray40',lty=2)
 legend('bottomright',c('Published life-evaluation score','Dashed line: unweighted reference mean'),pch=c(19,NA),lty=c(NA,2),col=c('#176B8A','gray40'),bty='n',cex=.85)
 mtext('Dots are scores, not ranks. Bars show provider 95% confidence intervals where available.',side=3,line=.8,cex=.8)
 mtext('Source: World Happiness Report 2026 / Gallup. Multi-year averages are not annual observations; missing bounds are not invented.',side=1,outer=TRUE,line=1,cex=.8)
})
# Explicitly mixed time windows are shown in the column headings rather than hidden.
year<-2024L
mat<-matrix(NA_real_,nrow(cases),5,dimnames=list(cases$name,c('Economy\n2024','Living standards\n2024','Life evaluation\n2022-2024','Freedom\n2024','Social outcomes\nNot scored')))
for(i in seq_len(nrow(cases))) {
 iso<-cases$iso3[i]
 for(j in 1:2){x<-s$score[s$iso3==iso & s$year==year & s$category==c('economic','living')[j]];if(length(x))mat[i,j]<-x[1]}
 x<-h$z[h$iso3==iso & h$period_end_year==year];if(length(x))mat[i,3]<-x[1]
 x<-f$score[f$iso3==iso & f$year==year];if(length(x))mat[i,4]<-x[1]
}
comparison_table<-data.frame(country_or_economy=rownames(mat),mat,check.names=FALSE)
names(comparison_table)<-gsub('\n',' - ',names(comparison_table),fixed=TRUE)
write_csv(comparison_table,'outputs/tables/five_area_comparison.csv')
plot_png('five_area_overview.png',{
 par(mar=c(7,11,5,6),oma=c(4,0,0,0));colors<-hcl.colors(101,'Blue-Red 3',rev=FALSE)
 plot(NA,xlim=c(.5,5.5),ylim=c(.5,nrow(mat)+.5),xaxt='n',yaxt='n',xlab='',ylab='',main='Development strengths and tradeoffs across five areas')
 for(i in seq_len(nrow(mat)))for(j in 1:5){x<-mat[i,j];fill<-if(is.na(x))'#E6E8EB' else colors[round((max(-3,min(3,x))+3)/6*100)+1]
 rect(j-.48,nrow(mat)-i+.52,j+.48,nrow(mat)-i+1.48,col=fill,border='white')
 text(j,nrow(mat)-i+1,if(is.na(x))'Not scored' else sprintf('%.2f',x),cex=.8)}
 axis(1,1:5,colnames(mat),tick=FALSE,cex.axis=.8);axis(2,rev(seq_len(nrow(mat))),rownames(mat),las=2,tick=FALSE,cex.axis=.85)
 mtext('Blue = below reference; red = above reference; grey = no defensible score. Numbers are relative scores.',side=3,line=.8,cex=.8)
 mtext('Economy, living standards and freedom: provisional means of indicator z-scores. Life evaluation: one standardized multi-year measure.',side=1,outer=TRUE,line=1,cex=.75)
 mtext('Each area uses its own available international reference; no overall ranking is calculated. Sources: World Bank, V-Dem v16, WHR 2026.',side=1,outer=TRUE,line=2.5,cex=.75)
})
plot_png('democracy_and_civil_liberties.png',{
 par(mfrow=c(1,2),mar=c(5,11,5,2),oma=c(4,0,1,0))
 for(code in c('v2x_polyarchy','v2x_civlib')) {
  d<-v[v$year==2024,];d<-d[match(cases$iso3,d$iso3),]
  plot(d[[code]],rev(seq_len(nrow(cases))),xlim=c(0,1),ylim=c(.5,nrow(cases)+.5),yaxt='n',pch=19,col='#176B8A',
   xlab='Index (0 = low; 1 = high)',ylab='',main=if(code=='v2x_polyarchy')'Electoral democracy in 2024' else 'Civil liberties in 2024',cex.main=.9)
  axis(2,rev(seq_len(nrow(cases))),cases$name,las=2,cex.axis=.75)
 }
 mtext('Source: V-Dem Country-Year v16. Expert-coded estimates, not counts or objective certainty; uncertainty is retained in the datasets.',side=1,outer=TRUE,line=1,cex=.75)
 mtext('These related indices share concepts. Their association must not be treated as an independent test of democracy effects.',side=1,outer=TRUE,line=2.5,cex=.75)
})
plot_png('democracy_association_sensitivity.png',{
 par(mfrow=c(1,3),mar=c(7,5,4,1),oma=c(4,0,2,0))
 titles<-c(economic_growth='Economic growth\n(percentage points)',living_available_basket='Living standards\n(provisional score units)',happiness_life_evaluation='Life evaluation\n(0-10 ladder points)')
 for(outcome in names(titles)) {
  vars<-c('year_effects_only','country_year_effects','without_income_control')
  d<-coef[coef$outcome==outcome & coef$term=='democracy',];d<-d[match(vars,d$variant),]
  plot(1:3,d$estimate,xlim=c(.4,3.6),ylim=range(c(0,d$lower,d$upper),na.rm=TRUE),xaxt='n',pch=19,
   xlab='',ylab='Association per 1-unit increase in democracy (0-1)',main=titles[[outcome]],cex.main=.85)
  arrows(1:3,d$lower,1:3,d$upper,angle=90,code=3,length=.05);abline(h=0,lty=2,col='gray50')
  axis(1,1:3,c('Year only','Country + year','No income'),las=2,cex.axis=.7)
 }
 mtext('How model choices change the estimated democracy association',side=3,outer=TRUE,line=.3,font=2,cex=1.15)
 mtext('Bars: country-clustered 95% confidence intervals. No-income model retains country and year effects. Samples may change with missingness.',side=1,outer=TRUE,line=1,cex=.75)
 mtext('Exploratory associations, not causal effects. Happiness uses non-overlapping reporting windows; other outcomes use annual observations.',side=1,outer=TRUE,line=2.5,cex=.75)
})
# Findings are generated from the actual saved data and model tables.
sg<-h[h$iso3=='SGP' & h$period_end_year==latest,]
benchmark<-unique(h$reference_mean[h$period_end_year==latest])[1]
models<-read.csv('outputs/tables/expanded_model_diagnostics.csv')
findings<-c('# Current research results','','Updated: 2026-11-04','',
 '## What is now available',
 '- World Bank data: 18 indicators, with coverage evaluated separately by year and indicator.',
 sprintf('- V-Dem v16: %d audited countries/economies and %s country-year records. All 11 selected cases are included.',length(unique(v$iso3)),format(nrow(v),big.mark=',')),
 sprintf('- Happiness: %d matched countries/economies across %d published reporting periods. All 11 cases have observations somewhere in the file.',length(unique(h$iso3)),length(unique(h$period_end_year))),
 sprintf('- %d exploratory model specifications, including openness, income-control and outcome-basket sensitivity.',nrow(models)),
 '', '## One descriptive finding',
 sprintf('Singapore has a published life-evaluation score of %.3f for %d-%d. The matched international reference mean for that period is %.3f. This does not support assuming Singapore must have below-average happiness.',sg$life_evaluation_score,latest-2,latest,benchmark),
 'The score is a survey-based multi-year life evaluation, not an annual happiness reading or a causal policy effect.',
 '', '## What the five areas mean now')
for(i in seq_len(nrow(status)))findings<-c(findings,paste0('### ',status$category[i]),status$available[i],paste('Current analysis:',status$modeling[i]),paste('Still unresolved:',status$unresolved[i]),'')
findings<-c(findings,'## Why the regression results remain provisional',
 'Broad state intervention is still unmeasured. A separate IMF general-government investment extension tests one narrower fiscal activity. Trade share measures realized flows and country structure, not policy openness alone.',
 'Democracy and freedom indices overlap conceptually. Democracy is therefore omitted from the freedom-outcome regression.',
 'Country and year effects, lagging and clustered standard errors do not remove all confounding, reverse causality, source error or sample selection.',
 'Happiness models use separate three-year windows and predictors from before each window. Annual Gallup data is not claimed.',
 'The separate social-survey extension models income and consumption within provider comparability spells. Unrestricted pooling across survey concepts is not used, and no social composite has been manufactured.',
 '', '## How to inspect results',
 'Open outputs/START_HERE.html for the main guide. Use data/readable and outputs/readable_tables for labeled CSV files.',
 'The model selections table shows missing-data sample loss. The VIF table shows collinearity after removing model fixed effects.',
 'Development-stage matching is exploratory and may be left-censored by the beginning of observed PPP data. Matching cannot establish transferability.',
 '', '## Next decisions',
 '1. Decide whether the narrower economic-growth models and provisional baskets answer the intended question.',
 '2. Review freedom measurement, social survey definitions and the absence of a defensible intervention measure.',
 '3. Review the historical-income, regional and balanced-reference sensitivity; add stronger case evidence before transferability claims.')
if(file.exists('outputs/tables/historical_and_regional_references.csv'))findings<-c(findings,
 '', '## Historical peers and coverage sensitivity',
 'The official World Bank income-classification history is now integrated. A classification is assigned to the calendar year in which it is in force on July 1, not to the earlier GNI data year.',
 'Raw peer means distinguish historical income groups from current geographic-region definitions. A balanced 2000-2024 reference keeps the same observed economies for each indicator; that selection is not automatically representative.',
 'The current-high-income-membership sensitivity is retained and remains a different benchmark. No small-group peer z-score is represented as a global score.')
writeLines(findings,'docs/current_results.md')
# The current overview uses small status tables and charts before detailed file listings.
esc<-function(x){x<-gsub('&','&amp;',x,fixed=TRUE);x<-gsub('<','&lt;',x,fixed=TRUE);gsub('>','&gt;',x,fixed=TRUE)}
html<-c('<!doctype html><html lang="en"><meta charset="utf-8"><title>SODA 308: Current results</title>',
 '<style>body{font:17px/1.65 system-ui;max-width:1100px;margin:35px auto;padding:0 24px;color:#203040}img{width:100%}table{border-collapse:collapse}td,th{border:1px solid #ddd;padding:12px;vertical-align:top;text-align:left}a{color:#075b9e}</style>',
 '<h1>Singapore development: current results</h1><p>Read the status of each area first, then inspect the charts. These results describe patterns and exploratory associations. They do not prove that a policy caused an outcome or can be transferred to another country.</p>',
 paste0('<p><strong>Example:</strong> ',esc(findings[grep('Singapore has a published',findings)]),'</p>'),
 '<h2>What is available in each area?</h2><table><tr><th>Area</th><th>Available now</th><th>Important limit</th></tr>')
for(i in seq_len(nrow(status)))html<-c(html,paste0('<tr><td>',esc(status$category[i]),'</td><td>',esc(status$available[i]),'</td><td>',esc(status$unresolved[i]),'</td></tr>'))
html<-c(html,'</table>')
plots<-c(five_area_overview='Strengths and tradeoffs: read the time labels carefully',happiness_latest_period='Latest published life-evaluation period',
 democracy_and_civil_liberties='Political institutions: related but distinct concepts',democracy_association_sensitivity='Model sensitivity: estimates change with assumptions')
if(file.exists('outputs/figures/singapore_life_expectancy_peers.png'))plots<-c(plots,singapore_life_expectancy_peers='Global, historical-income and regional peers give different benchmarks')
for(n in names(plots))html<-c(html,paste0('<h2>',plots[[n]],'</h2><img src="figures/',n,'.png" alt="',plots[[n]],'">'))
html<-c(html,'<h2>Where to go next</h2><ul><li><a href="START_HERE.html">All labeled datasets, original charts and file guide</a></li>',
 '<li><a href="../docs/current_results.md">Current findings and unresolved questions</a></li><li><a href="../docs/current_methods.md">Methods explained in plain language</a></li>',
 '<li><a href="readable_tables/expanded_model_coefficients.csv">Labeled model estimates</a></li><li><a href="readable_tables/expanded_model_selections.csv">Model sample sizes and missingness</a></li></ul>',
 '<p>Sources: World Bank WDI/WGI, V-Dem Country-Year v16, World Happiness Report 2026 / Gallup. Source versions, definitions, crosswalks and download records are preserved in metadata/.</p></html>')
writeLines(html,'outputs/CURRENT_RESULTS.html',useBytes=TRUE)
# Keep the familiar entry point and put the new overview first.
path<-'outputs/START_HERE.html'
if(file.exists(path)) {
 text<-paste(readLines(path,warn=FALSE),collapse='\n')
 if(!grepl('CURRENT_RESULTS.html',text,fixed=TRUE))text<-sub('<h2>Plots</h2>',
 '<h2>Latest research update</h2><p><a href="CURRENT_RESULTS.html">Open the current five-area overview, new sources and expanded analysis.</a></p><h2>Plots</h2>',text,fixed=TRUE)
 text<-sub('Happiness, freedom and social composites remain unavailable. The models omit democracy and a defensible state-intervention measure.',
 'The expanded analysis adds democracy, a descriptive freedom basket and multi-year happiness scores. Social composites and state intervention remain unresolved. Open the latest research update below.',text,fixed=TRUE)
 writeLines(text,path,useBytes=TRUE)
}
message('Current results report and additional plots updated.')



# Source-specific coverage accompanies the original World Bank quality report.
vl<-read.csv('data/clean/vdem_indicators_and_scores.csv')
cov<-do.call(rbind,lapply(split(vl[vl$year>=2000,],interaction(vl$code[vl$year>=2000],vl$year[vl$year>=2000],drop=TRUE)),function(d)
 data.frame(source='V-Dem v16',indicator=d$code[1],period=as.character(d$year[1]),n_observed=sum(is.finite(d$value)),reference_catalog=length(unique(v$iso3)))))
for(y in sort(unique(h$period_end_year))) {
 d<-h[h$period_end_year==y,];cov<-rbind(cov,data.frame(source='WHR 2026 / Gallup',indicator='Life evaluation (multi-year)',
 period=if(y>=2012)paste0(y-2,'-',y) else 'Early period ending 2011; start unassigned',n_observed=sum(is.finite(d$life_evaluation_score)),reference_catalog=length(unique(h$iso3))))
}
write_csv(cov,'outputs/tables/additional_source_coverage.csv')
read_cov<-cov
names(read_cov)<-c('Data source','Source indicator code','Observation year or reporting period','Economies with observed values','Matched reference catalog (all periods)')
write_csv(read_cov,'outputs/readable_tables/additional_source_coverage.csv')
quality<-c('# Data quality across all sources','',
 '## World Bank',
 'See outputs/data_quality_report.md for indicator-by-indicator missingness. The modern summary covers 2000-2025; annual models end in 2024. Education, poverty and inequality have substantial gaps.',
 '', '## V-Dem',
 'The country crosswalk retains 174 matched units. Annual coverage and normalization eligibility are exported separately by index and year. Historical raw values are not assumed territorially equivalent across time.',
 'Provider uncertainty bounds and standard deviations are preserved. Point-score regressions do not propagate the full provider measurement uncertainty.',
 '', '## Happiness',
 'The dataset includes 164 matched economies across 14 published reporting periods; individual periods cover fewer. The latest period has the observed count recorded in happiness_period_scores.csv.',
 'Multi-year averages are not independent annual observations. Model windows do not overlap. Missing early-period confidence bounds remain missing, and the early period start is not inferred.',
 'Original accented provider names are preserved using a tested Windows UTF-8 text setting. Values are checked against the original workbook.',
 '', '## Peer references',
 'Income-group membership uses the July 1 classification in force during the observation year. Unknown and retrospective starred classifications are not assigned a usable group.',
 'Regional membership is the current World Bank region definition. Balanced samples retain only economies observed in every year 2000-2024 for the relevant indicator, which changes the target population.',
 '', '## Reading sample sizes',
 'A reference count describes economies with observed values, not people surveyed. Regression observations are country-year rows or happiness windows. Model selection tables record losses from missing predictors.',
 'See additional_source_coverage.csv, coverage_by_year.csv, case_missingness.csv and expanded_model_selections.csv. The two validation text files record actual checks; a passing check is not a guarantee of source accuracy or causal validity.')
writeLines(quality,'outputs/COMPLETE_DATA_QUALITY.md')



