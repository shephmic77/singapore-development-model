source('scripts/text_encoding.R')
write_csv<-function(x,path)write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')
cases<-read.csv('metadata/primary_cases.csv');imf<-read.csv('data/clean/imf_public_investment.csv')
pmr<-read.csv('data/clean/oecd_public_ownership_assessments.csv');pip<-read.csv('data/clean/pip_survey_social_outcomes.csv')
sg<-read.csv('data/clean/singapore_gini_definitions.csv');coverage<-read.csv('outputs/tables/intervention_social_case_coverage.csv')
selections<-read.csv('outputs/tables/fiscal_social_model_selections.csv');coefs<-read.csv('outputs/tables/fiscal_social_model_coefs.csv')
plot_png<-function(name,expr,width=1500,height=1050){png(file.path('outputs/figures',name),width=width,height=height,res=140);tryCatch(force(expr),finally=dev.off())}
plot_png('public_investment_selected_cases.png',{
 par(mar=c(6,11,5,2),oma=c(3,0,0,0))
 d<-imf[imf$primary_case & imf$year %in% c(2010,2019),];limit<-max(d$government_investment_pct_gdp,na.rm=TRUE)*1.15
 plot(NA,xlim=c(0,limit),ylim=c(.5,nrow(cases)+.5),yaxt='n',xlab='General-government investment in fixed assets (percent of GDP)',ylab='',main='Public investment: observed values in 2010 and 2019')
 axis(2,rev(seq_len(nrow(cases))),cases$name,las=2,cex.axis=.85)
 for(i in seq_len(nrow(cases))){s<-d[d$iso3==cases$iso3[i],];s<-s[match(c(2010,2019),s$year),];y<-nrow(cases)-i+1
  if(all(is.finite(s$government_investment_pct_gdp)))segments(s$government_investment_pct_gdp[1],y,s$government_investment_pct_gdp[2],y,col='gray70')
  points(s$government_investment_pct_gdp,rep(y,2),pch=c(1,19),col=c('#777777','#176B8A'),cex=1.2)
 }
 legend('bottomright',c('2010','2019'),pch=c(1,19),col=c('#777777','#176B8A'),bty='n')
 mtext('A narrow measure of fiscal capital formation; it does not measure all state ownership or industrial policy.',side=3,line=.8,cex=.8)
 mtext('Source: IMF Investment and Capital Stock Dataset, May 2021 vintage. Same-source nominal investment / nominal GDP; data end in 2019.',side=1,outer=TRUE,line=1,cex=.75)
})
plot_png('oecd_ownership_coverage_and_dates.png',{
 par(mar=c(6,11,5,2),oma=c(3,0,0,0));d<-pmr[pmr$assessment_wave=='PMR_Econwide_2023-24',];d<-d[match(cases$iso3,d$iso3),]
 plot(NA,xlim=c(0,8),ylim=c(.5,nrow(cases)+.5),xaxt='n',yaxt='n',xlab='Public-ownership regulation score (0-6)',ylab='',main='OECD public ownership: coverage and assessment dates')
 axis(1,0:6);axis(2,rev(seq_len(nrow(cases))),cases$name,las=2,cex.axis=.85)
 for(i in seq_len(nrow(cases))){y<-nrow(cases)-i+1
  if(is.finite(d$public_ownership_distortion_score[i])){points(d$public_ownership_distortion_score[i],y,pch=19,col='#176B8A');text(6.3,y,d$legal_reference_date[i],adj=0,cex=.8)} else text(2.2,y,'No assessment in this workbook wave',col='gray45',cex=.75)
 }
 mtext('Dates on the right are the actual legal-reference dates. The wave name is not a common observation year.',side=3,line=.8,cex=.8)
 mtext('Source: OECD PMR workbook. Higher = more restrictive/distortionary ownership regulation, not a larger government-owned share.',side=1,outer=TRUE,line=1,cex=.75)
})
plot_png('social_survey_coverage.png',{
 mat<-matrix(0,nrow(cases),3,dimnames=list(cases$name,c('National income\nsurvey records','National consumption\nsurvey records','Non-national\nsurvey records')))
 for(i in seq_len(nrow(cases))){d<-pip[pip$iso3==cases$iso3[i] & pip$year>=2000 & pip$year<=2024,]
  mat[i,1]<-sum(d$national_eligible & d$welfare_type=='income',na.rm=TRUE)
  mat[i,2]<-sum(d$national_eligible & d$welfare_type=='consumption',na.rm=TRUE)
  mat[i,3]<-sum(!d$national_eligible,na.rm=TRUE)
 }
 par(mar=c(7,11,5,2),oma=c(3,0,0,0));plot(NA,xlim=c(.5,3.5),ylim=c(.5,nrow(cases)+.5),xaxt='n',yaxt='n',xlab='',ylab='',main='Which social surveys are available for the selected cases?')
 for(i in seq_len(nrow(cases)))for(j in 1:3){y<-nrow(cases)-i+1;rect(j-.48,y-.48,j+.48,y+.48,col=if(mat[i,j]>0)'#D8E9ED' else '#ECEEF0',border='white');text(j,y,mat[i,j])}
 axis(1,1:3,colnames(mat),tick=FALSE,cex.axis=.85);axis(2,rev(seq_len(nrow(cases))),cases$name,las=2,tick=FALSE,cex.axis=.85)
 mtext('Counts of observed survey records in 2000-2024, not annual coverage or quality scores.',side=3,line=.8,cex=.8)
 mtext('Source: World Bank PIP, September 2026 release. Zero means no records in this subset, not zero poverty or inequality.',side=1,outer=TRUE,line=1,cex=.8)
})
plot_png('singapore_gini_income_definitions.png',{
 par(mfrow=c(2,1),mar=c(5,5,4,2),oma=c(4,0,0,0))
 for(table in c('M810361','M810871')) {
  d<-sg[sg$table_id==table & sg$equivalence_scale=='Per household member' & sg$tax_transfer_treatment!='Including regular government contributions',]
  plot(NA,xlim=range(d$year),ylim=range(d$gini_0_100,na.rm=TRUE)+c(-1,1),xlab='Calendar year',ylab='Gini index (0-100; lower = less unequal)',
   main=if(table=='M810361')'Employment income: resident employed households' else 'Market income: resident households',cex.main=.95)
  for(treatment in c('Before government transfers and taxes','After government transfers and taxes')) {
   s<-d[d$tax_transfer_treatment==treatment,];s<-s[order(s$year),];col<-if(grepl('Before',treatment))'#B33B35' else '#176B8A'
   lines(s$year,s$gini_0_100,col=col,lwd=2,lty=if(grepl('Before',treatment))1 else 2)
  }
  legend('topright',c('Before transfers and taxes','After transfers and taxes'),col=c('#B33B35','#176B8A'),lty=c(1,2),lwd=2,bty='n',cex=.75)
 }
 mtext('Source: Singapore Department of Statistics, M810361 and M810871. Same per-household-member scale; populations and income concepts differ.',side=1,outer=TRUE,line=1,cex=.75)
 mtext('The two panels are not spliced or pooled with PIP. Before/after accounting differences do not identify causal policy effects.',side=1,outer=TRUE,line=2.5,cex=.75)
},height=1350)
plot_png('gini_survey_observations.png',{
 par(mfrow=c(4,3),mar=c(3,3,3,1),oma=c(5,2,2,0))
 for(i in seq_len(nrow(cases))){d<-pip[pip$iso3==cases$iso3[i] & pip$year>=2000 & pip$year<=2024,]
  plot(NA,xlim=c(2000,2024),ylim=c(0,70),xlab='Year',ylab='Gini (0-100)',main=cases$name[i],cex.main=.9)
  if(!nrow(d))text(2012,35,'No PIP survey records\nSee separate local-source notes',cex=.7)
  if(nrow(d))points(d$year,d$gini_0_100,col=ifelse(d$welfare_type=='income','#176B8A','#B33B35'),pch=ifelse(d$national_eligible,19,1),cex=.8)
 }
 plot.new();legend('center',c('Income welfare','Consumption welfare','Filled: national labels','Hollow: non-national'),col=c('#176B8A','#B33B35','black','black'),pch=c(19,19,19,1),bty='n',cex=.75)
 mtext('Survey observations are not a complete annual series',side=3,outer=TRUE,line=.3,font=2,cex=1.1)
 mtext('Source: World Bank PIP. Income and consumption have different meanings; non-national records remain separate. No missing years are filled.',side=1,outer=TRUE,line=1,cex=.75)
 mtext('Models use national labels and separate within-country comparability spells. Argentina is urban-only; Singapore/Hong Kong are absent from this PIP snapshot.',side=1,outer=TRUE,line=2.5,cex=.72)
},height=1500)
if(file.exists('data/clean/hong_kong_census_gini.csv')) {
 hk<-read.csv('data/clean/hong_kong_census_gini.csv')
 plot_png('hong_kong_census_gini_definitions.png',{
  par(mar=c(5,5,5,2),oma=c(3,0,0,0));plot(NA,xlim=c(2010,2022),ylim=c(35,44),xaxt='n',
   xlab='Census / by-census year (only these observed dates)',ylab='Gini index (0-100; lower = less unequal)',main='Hong Kong: the household population changes the Gini measure')
  axis(1,c(2011,2016,2021))
  for(pop in unique(hk$household_population)){d<-hk[hk$household_population==pop,];col<-if(pop=='All domestic households')'#176B8A' else '#B33B35'
   points(d$year,d$gini_0_100,pch=if(pop=='All domestic households')19 else 17,col=col,cex=1.4)}
  legend('topright',c('All domestic households','Economically active households'),col=c('#176B8A','#B33B35'),pch=c(19,17),bty='n',cex=.8)
  mtext('Both series: per-person household income after tax and social benefits; benefits include in-kind services.',side=3,line=.8,cex=.8)
  mtext('Source: Hong Kong Census and Statistics Department, 2021 thematic report, Table 6.1 (printed page 98). No annual interpolation.',side=1,outer=TRUE,line=1,cex=.75)
 })
}
# Summaries use estimated models only and retain different outcome units explicitly.
selected<-coefs[coefs$term=='public_investment' & coefs$model=='Matched sample: with public investment',]
labels<-c(economic_growth='Real GDP per capita growth (percentage points)',living_available_basket='Living standards (provisional category score)',gini_0_100='Gini inequality (0-100 points)',poverty_3usd_pct='Poverty below USD 3/day (percentage points; 2021 PPP)')
selected$outcome_label<-unname(labels[selected$outcome]);selected$coefficient_and_interval<-sprintf('%.3f [%.3f, %.3f]',selected$estimate,selected$lower,selected$upper)
small<-selected$outcome=='living_available_basket'
selected$coefficient_and_interval[small]<-sprintf('%.4f [%.4f, %.4f]',selected$estimate[small],selected$lower[small],selected$upper[small])
uncertainty_note<-sprintf('%d of %d main matched-sample public-investment estimates have 95%% confidence intervals that include zero. These specifications do not establish a reliable direction of association; this is not proof that the true effect is zero.',sum(selected$lower<=0 & selected$upper>=0),nrow(selected))
selected$coefficient_unit<-'Outcome change associated with +1 percentage point of GDP in previous-year government fixed investment'
write_csv(selected,'outputs/tables/public_investment_association_summary.csv')
sglatest<-sg[sg$year==max(sg$year) & sg$equivalence_scale=='Per household member' & sg$tax_transfer_treatment=='After government transfers and taxes',]
findings<-c('# State intervention and social outcomes: current update','','## Main points',
 '1. Public investment is now measurable for all 11 cases in the IMF workbook. It captures one fiscal activity, not the full developmental-state model.',
 '2. OECD public-ownership regulation scores are available for only some cases and have mixed legal-reference dates. They are retained as periodic descriptions, not filled into an annual predictor.',
 '3. PIP now supplies survey definitions and comparability spells for poverty and inequality. National income and consumption observations are analyzed separately.',
 '4. Official Singapore inequality series and six verified Hong Kong census values are collected as separate case studies. Their definitions are not silently combined.',
 '', '## What the new data supports',
 sprintf('The pipeline attempted %d additional model specifications and estimated %d after the sample gates.',nrow(selections),sum(selections$status=='Estimated')),
 'Public-investment extensions compare models with and without the investment term on exactly the same complete-case sample. The main annual outcome window ends in 2019; a labeled sensitivity includes 2020.',
 'Social models use nationally labeled survey estimates, separate income/consumption concepts, and fixed effects for provider comparability blocks and reporting years. Each block needs at least three usable survey years; each model needs 100 observations and 30 economies.',
 'The result is a set of exploratory within-block associations, not a universally harmonized social score or a causal effect.',
 '', '## Preliminary uncertainty finding',uncertainty_note,'', '## What remains unresolved',
 'General-government investment excludes much state-company activity, directed credit, industrial-policy design and government ownership through holding companies. IMF May 2021 data end in 2019. It is a narrow proxy, not a replacement name for total state intervention.',
 'PIP does not cover Singapore or Hong Kong in the pinned snapshot. Argentina has urban-only survey coverage and is excluded from national-survey models. This does not mean these economies have no inequality or poverty.',
 'Even national labels and provider comparability spells cannot guarantee identical cross-country survey concepts. The model outcomes are bounded percentages/indices, while the exploratory linear models do not constrain predictions to those bounds.',
 'No social composite is created. Related inequality shares are reported as supporting distribution measures, not independently weighted components.',
 '', '## Where to look',
 '- Open outputs/INTERVENTION_SOCIAL.html for the simple visual report.',
 '- Read docs/intervention_social_methods.md for definitions and modeling choices.',
 '- Read docs/intervention_social_sources.md for source terms, versions and remaining coverage gaps.',
 '- Use outputs/readable_tables/intervention_social_case_coverage.csv for all 11 case statuses.',
 '- Use data/readable for labeled copies of the new datasets.')
writeLines(findings,'docs/intervention_social_findings.md')
esc<-function(x){x<-gsub('&','&amp;',x,fixed=TRUE);x<-gsub('<','&lt;',x,fixed=TRUE);gsub('>','&gt;',x,fixed=TRUE)}
html<-c('<!doctype html><html lang="en"><meta charset="utf-8"><title>SODA 308: Intervention and social outcomes</title>',
 '<style>body{font:17px/1.65 system-ui;max-width:1150px;margin:35px auto;padding:0 24px;color:#203040}img{width:100%}table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:10px;text-align:left;vertical-align:top}a{color:#075b9e}.note{background:#eef4f7;padding:18px;border-radius:8px}</style>',
 '<h1>State intervention and social outcomes</h1><p class="note"><strong>What changed:</strong> The project now measures general-government investment, audits OECD public-ownership assessments, and uses survey-level definitions for poverty and inequality. These sources answer narrower questions. They do not complete a universal state-intervention index or a fully comparable social score.</p>',
 '<h2>Three distinctions to keep in mind</h2><ol><li><strong>Government investment is one activity.</strong> It is not the whole system of state ownership or industrial policy.</li><li><strong>Income and consumption are different.</strong> Their poverty and inequality observations are not pooled as identical outcomes.</li><li><strong>Survey coverage matters.</strong> Urban-only results are not treated as nationally representative.</li></ol>',
 '<h2>Coverage for the 11 selected cases</h2><table><tr><th>Case</th><th>IMF public investment</th><th>OECD ownership assessments</th><th>PIP social-survey status</th></tr>')
for(i in seq_len(nrow(coverage)))html<-c(html,paste0('<tr><td>',esc(coverage$name[i]),'</td><td>',coverage$public_investment_years[i],
 ' observed years through ',coverage$public_investment_last_year[i],'</td><td>',coverage$pmr_assessments[i],
 ' assessments; actual dates retained</td><td>',esc(coverage$pip_status[i]),'</td></tr>'))
html<-c(html,'</table><p>Full definitions, dates and source labels are in the labeled coverage table. “Not covered” means absent from this downloaded source, not that the outcome is zero.</p>')
plots<-c(public_investment_selected_cases='Public investment: same measure and same comparison years',oecd_ownership_coverage_and_dates='Ownership regulation: missing cases and different dates',
 social_survey_coverage='Available surveys: income, consumption and coverage',singapore_gini_income_definitions='Singapore: why the income definition changes the picture',gini_survey_observations='Observed inequality points: gaps remain visible')
if(file.exists('outputs/figures/hong_kong_census_gini_definitions.png'))plots<-c(plots,hong_kong_census_gini_definitions='Hong Kong: separate census definitions, not annual PIP data')
for(n in names(plots))html<-c(html,paste0('<h2>',plots[[n]],'</h2><img src="figures/',n,'.png" alt="',plots[[n]],'">'))
html<-c(html,'<h2>Public-investment associations: main matched samples</h2><p>Each row estimates the association with one additional percentage point of GDP in previous-year government investment. Brackets show country-clustered 95% confidence intervals. Units differ by outcome. These are not causal effects.</p>',
 '<table><tr><th>Outcome</th><th>Survey concept</th><th>Coefficient [95% interval]</th><th>Observations / economies</th></tr>')
for(i in seq_len(nrow(selected)))html<-c(html,paste0('<tr><td>',esc(selected$outcome_label[i]),'</td><td>',esc(selected$welfare_type[i]),
 '</td><td>',selected$coefficient_and_interval[i],'</td><td>',format(selected$n[i],big.mark=','),' / ',selected$economies[i],'</td></tr>'))
html<-c(html,'</table><p>For Gini and poverty, a positive coefficient means more measured inequality or poverty, not a better outcome. Missing-data sample loss, alternative specifications and collinearity diagnostics are exported.</p>',
 '<h2>Documentation and labeled files</h2><ul><li><a href="../docs/intervention_social_findings.md">Findings and remaining gaps</a></li><li><a href="../docs/intervention_social_methods.md">Methods in plain language</a></li><li><a href="../docs/intervention_social_sources.md">Sources, terms and exact definitions</a></li>',
 '<li><a href="readable_tables/intervention_social_case_coverage.csv">Case coverage table</a></li><li><a href="readable_tables/fiscal_social_model_coefs.csv">All new model coefficients</a></li><li><a href="readable_tables/fiscal_social_model_selections.csv">Sample gates and missing-data losses</a></li>',
 '<li><a href="CURRENT_RESULTS.html">Main project overview</a></li><li><a href="START_HERE.html">All labeled datasets and file guide</a></li></ul>',
 '<p>Sources: IMF Investment and Capital Stock Dataset (May 2021), OECD PMR workbook, World Bank PIP (September 2026 release, 2021 PPP), and Singapore Department of Statistics. These are research transformations, not official interpretations by the providers.</p></html>')
marker<-which(grepl('<h2>Public-investment associations',html,fixed=TRUE))[1]
if(!is.na(marker))html<-append(html,paste0('<p class="note">',esc(uncertainty_note),'</p>'),after=marker-1)
writeLines(html,'outputs/INTERVENTION_SOCIAL.html',useBytes=TRUE)
for(path in c('outputs/CURRENT_RESULTS.html','outputs/START_HERE.html'))if(file.exists(path)) {
 text<-paste(readLines(path,warn=FALSE),collapse='\n')
 if(!grepl('INTERVENTION_SOCIAL.html',text,fixed=TRUE))text<-sub('</h1>','</h1><p class="note"><strong>Latest update:</strong> <a href="INTERVENTION_SOCIAL.html">State-intervention measures and social-outcome survey audit: new data, charts and models.</a></p>',text,fixed=TRUE)
 writeLines(text,path,useBytes=TRUE)
}
message('State-intervention and social-outcome report updated.')


quality<-c('# Fiscal and social data quality','',
 '## What is checked',
 'Original IMF values and same-source ratio; OECD values and actual legal-reference dates; PIP source-value conversions and national labels; Singapore original series; exact model lags and paired samples; source checksums.',
 'Hong Kong consists of six curated values checked visually against the rendered official source. Automated checks preserve that transcription; they are not an independent OCR audit.',
 '', '## Coverage and missingness',
 sprintf('IMF investment ratio: %d matched economies with some usable observations; the source ends in 2019.',length(unique(imf$iso3[is.finite(imf$government_investment_pct_gdp)]))),
 sprintf('PIP: %d matched economies and %d survey records in the retained 1965-2025 scope.',length(unique(pip$iso3)),nrow(pip)),
 'The case table distinguishes record counts from population outcomes. A count of zero means source absence in that subset. No poverty or inequality value is filled with zero.',
 'Income, consumption and non-national coverage are preserved separately. See source-specific annual counts, welfare-type references and the model sample-selection table.',
 '', '## What a passing check cannot prove',
 'Survey labels do not guarantee identical definitions across countries. Some measures use modeled or approximated source inputs. Measurement uncertainty is not fully propagated into regressions.',
 'Country clustering does not eliminate confounding, reverse causality, policy endogeneity, selective missingness or cross-country dependence. Public investment is a narrow fiscal activity, not a complete state-intervention construct.')
writeLines(quality,'outputs/INTERVENTION_SOCIAL_DATA_QUALITY.md')
path<-'outputs/COMPLETE_DATA_QUALITY.md'
if(file.exists(path)) {
 text<-readLines(path,warn=FALSE)
 if(!any(grepl('INTERVENTION_SOCIAL_DATA_QUALITY.md',text,fixed=TRUE)))writeLines(c(text,'','## Latest fiscal/social extension','See INTERVENTION_SOCIAL_DATA_QUALITY.md and intervention_social_validation.txt for the newly added sources and checks.'),path)
}

