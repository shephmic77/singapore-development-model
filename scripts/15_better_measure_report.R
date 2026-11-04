source('scripts/text_encoding.R')
write_csv<-function(x,path)write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')
cases<-read.csv('metadata/primary_cases.csv');own<-read.csv('data/clean/state_ownership_control.csv')
sw<-read.csv('data/clean/swiid_standardized_income_inequality.csv');gii<-read.csv('data/clean/undp_gender_inequality.csv')
imf<-read.csv('data/clean/imf_public_investment.csv');coverage<-read.csv('outputs/tables/ownership_social_case_coverage.csv')
common<-read.csv('outputs/tables/swiid_same_year_case_comparison.csv');year<-unique(common$year);stopifnot(length(year)==1)
co<-read.csv('outputs/tables/ownership_model_coefs.csv');selection<-read.csv('outputs/tables/ownership_model_selections.csv')
plot_png<-function(name,expr,width=1500,height=1050){png(file.path('outputs/figures',name),width=width,height=height,res=140);tryCatch(force(expr),finally=dev.off())}
plot_png('ownership_and_investment_2019.png',{
 par(mfrow=c(1,2),mar=c(6,10,5,2),oma=c(4,0,0,0))
 a<-own[own$year==2019,];a<-a[match(cases$iso3,a$iso3),]
 b<-imf[imf$year==2019,];b<-b[match(cases$iso3,b$iso3),];y<-rev(seq_len(nrow(cases)))
 plot(a$ownership_control_0_4,y,xlim=c(0,4),ylim=c(.5,nrow(cases)+.5),yaxt='n',pch=19,col='#176B8A',
  xlab='Expert index (0-4; higher = more control)',ylab='',main='State ownership / direct control',cex.main=.9)
 axis(2,y,cases$name,las=2,cex.axis=.8);arrows(a$ownership_lower_bound,y,a$ownership_upper_bound,y,angle=90,code=3,length=.04,col='#176B8A')
 plot(b$government_investment_pct_gdp,y,xlim=c(0,max(b$government_investment_pct_gdp,na.rm=TRUE)*1.15),ylim=c(.5,nrow(cases)+.5),yaxt='n',pch=19,col='#B33B35',
  xlab='Government fixed investment (percent GDP)',ylab='',main='Public investment in fixed assets',cex.main=.9)
 axis(2,y,cases$name,las=2,cex.axis=.8)
 mtext('Same comparison year: 2019. The two measures describe different activities; neither is a complete intervention index.',side=1,outer=TRUE,line=1,cex=.8)
 mtext('Sources: V-Dem v16 (left, provider uncertainty bounds) and IMF May 2021 vintage (right). Bounds are not 95% regression intervals.',side=1,outer=TRUE,line=2.5,cex=.75)
})
plot_png('state_ownership_case_trends.png',{
 par(mfrow=c(4,3),mar=c(3,3,3,1),oma=c(4,2,2,0))
 for(iso in cases$iso3){d<-own[own$iso3==iso & own$year>=2000,];d<-d[order(d$year),]
  plot(NA,xlim=c(2000,2025),ylim=c(0,4),xlab='Year',ylab='Control index (0-4)',main=cases$name[match(iso,cases$iso3)],cex.main=.9)
  good<-complete.cases(d[c('year','ownership_lower_bound','ownership_upper_bound')]);s<-d[good,]
  polygon(c(s$year,rev(s$year)),c(s$ownership_lower_bound,rev(s$ownership_upper_bound)),col='#DCEAF1',border=NA)
  lines(d$year,d$ownership_control_0_4,col='#176B8A',lwd=2)
 }
 plot.new();text(.5,.6,'Higher = more state ownership / control\nNot a percentage of assets\nNot automatically better or worse',cex=.8)
 mtext('State ownership and direct control: expert assessments over time',side=3,outer=TRUE,line=.3,font=2,cex=1.1)
 mtext('Source: V-Dem v16, reversed expected original scale (4 minus v2clstown_osp). Shading shows provider uncertainty bounds, not 95% model intervals.',side=1,outer=TRUE,line=1,cex=.73)
 mtext('Repeated values do not prove no policy change; expert coverage and measurement uncertainty must be considered.',side=1,outer=TRUE,line=2.5,cex=.75)
},height=1500)
plot_png('standardized_inequality_common_year.png',{
 d<-common[match(cases$iso3,common$iso3),];y<-rev(seq_len(nrow(cases)))
 par(mar=c(6,11,5,2),oma=c(3,0,0,0))
 plot(NA,xlim=c(0,75),ylim=c(.3,nrow(cases)+.7),yaxt='n',xlab='Standardized household-income Gini (0-100; lower = less unequal)',ylab='',
  main=paste0('Comparable income concepts: all 11 cases in ',year))
 axis(2,y,cases$name,las=2,cex.axis=.85)
 points(d$gini_disp,y+.12,pch=19,col='#176B8A');arrows(d$disposable_lower95,y+.12,d$disposable_upper95,y+.12,angle=90,code=3,length=.04,col='#176B8A')
 points(d$gini_mkt,y-.12,pch=17,col='#B33B35');arrows(d$market_lower95,y-.12,d$market_upper95,y-.12,angle=90,code=3,length=.04,col='#B33B35')
 legend('bottomright',c('Disposable income: after taxes/transfers','Market income: before taxes/transfers'),pch=c(19,17),col=c('#176B8A','#B33B35'),bty='n',cex=.8)
 mtext('Provider-standardized/model-based estimates, not direct survey observations. Bars: approximate 95% provider uncertainty.',side=3,line=.8,cex=.75)
 mtext('Source: SWIID 9.92 published summary. Square-root household equivalence scale. 2016 is the latest year shared by all 11 cases.',side=1,outer=TRUE,line=1,cex=.75)
})
plot_png('gender_inequality_2023.png',{
 d<-gii[gii$year==2023,];d<-d[match(cases$iso3,d$iso3),];y<-rev(seq_len(nrow(cases)))
 par(mar=c(6,11,5,2),oma=c(3,0,0,0))
 plot(d$gender_inequality_index,y,xlim=c(0,1),ylim=c(.5,nrow(cases)+.5),yaxt='n',pch=19,col='#176B8A',
  xlab='Gender Inequality Index (0 = low inequality; 1 = high)',ylab='',main='Gender inequality in 2023: a separate social dimension')
 axis(2,y,cases$name,las=2,cex.axis=.85)
 for(i in which(!is.finite(d$gender_inequality_index)))text(.45,y[i],'No UNDP value; not imputed',col='gray40',cex=.8)
 mtext('Dimensions: reproductive health, empowerment and labor-market participation. Not a wage-gap percentage.',side=3,line=.8,cex=.8)
 mtext('Source: UNDP Human Development Report 2025, same-vintage time series. Health and education overlap with other project dimensions.',side=1,outer=TRUE,line=1,cex=.75)
})
plot_png('ownership_association_main_models.png',{
 par(mfrow=c(1,3),mar=c(5,5,5,2),oma=c(4,0,2,0))
 labels<-c(economic_growth='Economic growth\n(percentage points)',living_available_basket='Living standards\n(provisional score units)',gender_inequality_index='Gender inequality\n(index 0-1)')
 for(outcome in names(labels)) {
  d<-co[co$outcome==outcome & co$model=='Ownership/direct-control specification' & co$term=='state_control',]
  plot(1,d$estimate,xlim=c(.5,1.5),ylim=range(c(0,d$lower,d$upper)),xaxt='n',pch=19,col='#176B8A',
   xlab='',ylab='Association per 1 index point of state control (0-4)',main=labels[[outcome]],cex.main=.9)
  arrows(1,d$lower,1,d$upper,angle=90,code=3,length=.1,col='#176B8A');abline(h=0,lty=2,col='gray50')
  axis(1,1,'Country + year effects',cex.axis=.7)
  mtext(paste0(format(d$n,big.mark=','),' rows; ',d$economies,' economies'),side=1,line=3,cex=.7)
 }
 mtext('Ownership associations: exploratory models, not causal effects',side=3,outer=TRUE,line=.2,font=2,cex=1.1)
 mtext('Bars: country-clustered 95% confidence intervals. Predictors use the previous year. Higher GII means more gender inequality.',side=1,outer=TRUE,line=1,cex=.75)
 mtext('V-Dem predictor measurement uncertainty is not propagated. Same-provider measurement, slow changes and omitted policy factors remain concerns.',side=1,outer=TRUE,line=2.5,cex=.73)
})
summary<-co[co$term=='state_control' & co$model=='Ownership/direct-control specification',]
summary$coefficient_and_interval<-sprintf('%.4f [%.4f, %.4f]',summary$estimate,summary$lower,summary$upper)
write_csv(summary,'outputs/tables/main_ownership_associations.csv')
findings<-c('# Better state and social measures: current update','',
 '## What improved',
 'State ownership/direct control is now measured separately from government investment. V-Dem asks about ownership/control of important sectors and covers all 11 cases through 2025. It is an expert assessment, not a count of state-owned firms or an asset percentage.',
 'SWIID adds standardized disposable- and market-income inequality concepts using a common household equivalence scale. These are provider-modeled estimates with uncertainty, not newly observed survey records.',
 'UNDP adds a standardized gender-inequality dimension through 2023. Hong Kong has no value in this release and remains missing.',
 '', '## Coverage and fair comparisons',
 paste('The latest year shared by all 11 SWIID cases is',year,'. The common-year chart uses that year for everyone.'),
 'Newer values are retained for countries where the provider supplies them. A missing country-year is not forward-filled or silently replaced with another year.',
 '', '## New analysis',
 sprintf('%d ownership model specifications were estimated. Annual models cover growth, living standards and gender inequality; observed-survey models retain separate welfare concepts and comparability blocks.',sum(selection$status=='Estimated')),
 'The ownership specification includes democracy, trade, government effectiveness and ownership/direct control, plus income/population controls and country/year effects. It measures one state-involvement facet, not every industrial-policy tool.',
 'A matched baseline omits ownership; an alternative uses the reversed latent scale. Two joint specifications retain public investment in the shorter pre-2020 window.',
 '', '## Important quality gate',
 'The SWIID supplied draw formats did not pass the project\'s scale/summary-concordance audit. The R draws are not on the published Gini scale, and a diagnostic division by 100 does not resolve all summary discrepancies. Stata draws are on the Gini scale but also have unresolved discrepancies.',
 'This is a documented unresolved compatibility issue, not an assertion that the provider is wrong. No guessed rescaling, new artificial draws or SWIID draw-based regression is used. Published summaries are used only for clearly labeled descriptive comparisons, as the provider recommends for graphing.',
 'The corrected September 2026 WIID Companion was identified but its official download returned HTTP 403. No bypass or substitute copy was used.',
 '', '## What remains unresolved',
 'Expert ownership estimates do not measure directed credit, detailed industrial policy, implementation quality or all government-company activity. Their uncertainty and shared V-Dem measurement with democracy limit interpretation.',
 'Standardization improves the consistency of income concepts by imposing modeling assumptions; it does not make every estimate a directly comparable observed national survey.',
 'Gender inequality overlaps some health and education measures already used elsewhere. The project therefore keeps these dimensions separate and does not create a universal social composite or an overall country ranking.',
 '', '## Read next',
 '- outputs/BETTER_MEASURES.html: simple visual report.',
 '- docs/better_measure_methods.md: definitions, choices and limits.',
 '- docs/better_measure_sources.md: source versions, terms and candidate decisions.',
 '- outputs/readable_tables/ownership_social_case_coverage.csv: all 11 cases and actual last years.',
 '- outputs/readable_tables/swiid_draw_format_audit.csv: the unresolved format audit.')
writeLines(findings,'docs/better_measure_findings.md')
esc<-function(x){x<-gsub('&','&amp;',x,fixed=TRUE);x<-gsub('<','&lt;',x,fixed=TRUE);gsub('>','&gt;',x,fixed=TRUE)}
html<-c('<!doctype html><html lang="en"><meta charset="utf-8"><title>SODA 308: Better measures</title>',
 '<style>body{font:17px/1.65 system-ui;max-width:1150px;margin:35px auto;padding:0 24px;color:#203040}img{width:100%}table{border-collapse:collapse;width:100%}td,th{border:1px solid #ddd;padding:10px;text-align:left;vertical-align:top}.note{background:#edf4f7;padding:18px;border-radius:8px}a{color:#075b9e}</style>',
 '<h1>Better measures of state involvement and social outcomes</h1>',
 '<p class="note"><strong>Three separate improvements:</strong> state ownership/direct control, standardized income-inequality estimates, and gender inequality. The data types and assumptions differ. None is presented as a complete development score.</p>',
 '<h2>What each measure means</h2><table><tr><th>Measure</th><th>Plain meaning</th><th>Important limit</th></tr>',
 '<tr><td>V-Dem ownership/control</td><td>Expert assessment of how much important capital/sectors the state owns or controls</td><td>Not an ownership percentage or a full industrial-policy measure</td></tr>',
 '<tr><td>SWIID inequality summaries</td><td>Modeled estimates standardized toward the same household-income concepts</td><td>Not direct survey observations; uncertainty is shown; draw-based regression is withheld</td></tr>',
 '<tr><td>UNDP gender inequality</td><td>Published composite of reproductive health, empowerment and labor-market disadvantage</td><td>Not a wage-gap percentage; overlaps other dimensions; Hong Kong missing</td></tr></table>',
 '<h2>Coverage for the 11 cases</h2><table><tr><th>Case</th><th>Ownership: last year</th><th>SWIID: last year</th><th>Gender index: last year</th></tr>')
for(i in seq_len(nrow(coverage)))html<-c(html,paste0('<tr><td>',esc(coverage$name[i]),'</td><td>',coverage$ownership_last_year[i],'</td><td>',coverage$swiid_last_year[i],
 '</td><td>',if(is.na(coverage$gii_last_year[i]))'No value; not imputed' else coverage$gii_last_year[i],'</td></tr>'))
html<-c(html,'</table><p>“Last year” is coverage information, not permission to compare different latest years as if they were the same date.</p>')
plots<-c(ownership_and_investment_2019='Ownership and investment describe different facets',state_ownership_case_trends='Ownership estimates and their provider uncertainty',
 standardized_inequality_common_year='Same-year income concepts, with uncertainty',gender_inequality_2023='A separate gender dimension',ownership_association_main_models='Ownership associations and model uncertainty')
for(n in names(plots))html<-c(html,paste0('<h2>',plots[[n]],'</h2><img src="figures/',n,'.png" alt="',plots[[n]],'">'))
html<-c(html,'<h2>Why SWIID draw-based regression is withheld</h2><p>The supplied draw formats did not pass the project scale/summary-concordance audit. No arbitrary rescaling or replacement draws were used. The published summaries remain descriptive, provider-modeled estimates. This unresolved issue should be clarified before using these draws in statistical inference.</p>',
 '<h2>Documentation and data</h2><ul><li><a href="../docs/better_measure_findings.md">Findings and remaining gaps</a></li><li><a href="../docs/better_measure_methods.md">Methods in plain language</a></li><li><a href="../docs/better_measure_sources.md">Sources, terms and rejected candidates</a></li>',
 '<li><a href="readable_tables/ownership_social_case_coverage.csv">Case coverage table</a></li><li><a href="readable_tables/ownership_model_coefs.csv">Ownership model coefficients</a></li><li><a href="readable_tables/swiid_draw_format_audit.csv">SWIID format audit</a></li>',
 '<li><a href="INTERVENTION_SOCIAL.html">Earlier fiscal and observed-survey analysis</a></li><li><a href="CURRENT_RESULTS.html">Broader project overview</a></li><li><a href="START_HERE.html">All labeled datasets</a></li></ul>',
 '<p>Sources: V-Dem Country-Year v16, SWIID 9.92 / Solt (2020), UNDP Human Development Report 2025, and IMF Investment and Capital Stock Dataset (May 2021). These are research transformations, not official provider interpretations.</p></html>')
writeLines(html,'outputs/BETTER_MEASURES.html',useBytes=TRUE)
for(path in c('outputs/CURRENT_RESULTS.html','outputs/START_HERE.html','outputs/INTERVENTION_SOCIAL.html'))if(file.exists(path)) {
 text<-paste(readLines(path,warn=FALSE),collapse='\n')
 if(!grepl('BETTER_MEASURES.html',text,fixed=TRUE))text<-sub('</h1>','</h1><p><strong>Latest research:</strong> <a href="BETTER_MEASURES.html">Ownership/direct control and more comparable social measures.</a></p>',text,fixed=TRUE)
 writeLines(text,path,useBytes=TRUE)
}
message('Better-measures report and five additional plots updated.')
