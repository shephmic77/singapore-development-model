source('scripts/text_encoding.R')
# Collect and audit new sources. Always keep the original provider files.
.libPaths(c(normalizePath('.R-library'),.libPaths()))
stopifnot(requireNamespace('jsonlite',quietly=TRUE),requireNamespace('readxl',quietly=TRUE))
options(timeout=180)
write_csv<-function(x,p)write.csv(x,p,row.names=FALSE,na='',fileEncoding='UTF-8')
sha<-'f4dd26922e658442524dfd954bf14f7ebe622d5d'
sources<-data.frame(file=c('v16_vdem.RData','v16_codebook.RData','WHR26_Data_Figure_2.1.xlsx'),
 url=c(paste0('https://raw.githubusercontent.com/vdeminstitute/vdemdata/',sha,'/data/vdem.RData'),
 paste0('https://raw.githubusercontent.com/vdeminstitute/vdemdata/',sha,'/data/codebook.RData'),
 'https://files.worldhappiness.report/WHR26_Data_Figure_2.1.xlsx'),
 version=c('V-Dem v16','V-Dem v16','World Happiness Report 2026'),
 terms=c('CC BY-SA 4.0; cite V-Dem v16; share-alike applies to derivatives',
 'CC BY-SA 4.0; cite V-Dem v16', 'Public aggregate download; cite WHR 2026 and Gallup; no rights assumed for underlying microdata'))
for(i in seq_len(nrow(sources))) {
 p<-file.path('data/raw',sources$file[i]);if(!file.exists(p)) {
   tmp<-paste0(p,'.part'); download.file(sources$url[i],tmp,mode='wb',quiet=TRUE)
   stopifnot(file.rename(tmp,p))
 }
}
sources$file<-file.path('data/raw',sources$file)
sources$download_file_time_utc<-format(file.info(sources$file)$mtime,tz='UTC',usetz=TRUE)
sources$md5<-unname(tools::md5sum(sources$file))
sources$time_note<-'Recorded from local downloaded-file modification time'
write_csv(sources,'metadata/additional_source_manifest.csv')
wb<-read.csv('metadata/countries.csv',stringsAsFactors=FALSE)
cases<-read.csv('metadata/primary_cases.csv',stringsAsFactors=FALSE)
e<-new.env();load('data/raw/v16_vdem.RData',envir=e)
vars<-c('v2x_polyarchy','v2x_libdem','v2x_civlib','v2x_freexp_altinf','v2x_frassoc_thick')
keep<-c('country_name','country_text_id','year',vars,unlist(lapply(vars,function(x)paste0(x,c('_codelow','_codehigh','_sd')))))
v<-e$vdem[e$vdem$year>=1965 & e$vdem$year<=2025,keep];rm(e);gc(verbose=FALSE)
codebook_env<-new.env();load('data/raw/v16_codebook.RData',envir=codebook_env)
cb<-codebook_env$codebook[codebook_env$codebook$tag %in% vars,]
write_csv(cb,'metadata/vdem_selected_definitions.csv')
# Code equality is necessary but not sufficient: West Bank is not West Bank + Gaza.
cross<-unique(v[c('country_text_id','country_name')]);cross$iso3<-ifelse(cross$country_text_id %in% wb$iso3,cross$country_text_id,NA)
cross$match_status<-ifelse(is.na(cross$iso3),'Excluded: outside WB reference or distinct historical unit','Exact code; name and territorial scope reviewed')
cross$match_status[cross$country_text_id=='PSE']<-'Excluded: V-Dem West Bank is not WB combined West Bank and Gaza'
cross$iso3[cross$country_text_id=='PSE']<-NA
cross$historical_note<-'Pre-2000 reference comparability is not assumed; retain raw history only'
write_csv(cross,'metadata/vdem_country_crosswalk.csv')
v<-merge(v,cross[c('country_text_id','iso3','match_status')],by='country_text_id',all.x=TRUE)
v<-v[!is.na(v$iso3),];stopifnot(!anyDuplicated(v[c('iso3','year')]),all(cases$iso3 %in% v$iso3))
v$name<-wb$name[match(v$iso3,wb$iso3)];v$primary_case<-v$iso3 %in% cases$iso3
v$historical_comparability<-ifelse(v$year<2000,'Raw historical series; boundary/continuity review needed','Modern exact-code reference with territorial exclusions')
write_csv(v,'data/clean/vdem_country_year.csv')
# Descriptive freedom basket. Expression and association are also ingredients of democracy;
# never put this basket on the left with electoral democracy on the right.
long<-do.call(rbind,lapply(vars,function(code)data.frame(iso3=v$iso3,year=v$year,code=code,
 value=v[[code]],provider_lower=v[[paste0(code,'_codelow')]],provider_upper=v[[paste0(code,'_codehigh')]],
 provider_sd=v[[paste0(code,'_sd')]],name=v$name,primary_case=v$primary_case)))
long$z<-NA_real_;refs<-list()
for(code in vars)for(y in 2000:2025) {
 ids<-which(long$code==code & long$year==y);x<-long$value[ids];good<-is.finite(x);n<-sum(good)
 valid<-n>=100 && is.finite(sd(x[good])) && sd(x[good])>0
 if(valid)long$z[ids]<-(x-mean(x[good]))/sd(x[good])
 refs[[length(refs)+1]]<-data.frame(code=code,year=y,n_observed=n,reference_mean=mean(x[good]),reference_sd=sd(x[good]),eligible=valid)
}
write_csv(long,'data/clean/vdem_indicators_and_scores.csv')
write_csv(do.call(rbind,refs),'outputs/tables/vdem_reference_by_year.csv')
freedom_codes<-c('v2x_civlib','v2x_freexp_altinf','v2x_frassoc_thick')
f<-long[long$code %in% freedom_codes & long$year>=2000,]
freedom<-do.call(rbind,lapply(split(f,interaction(f$iso3,f$year,drop=TRUE)),function(d) {
 n<-sum(is.finite(d$z));data.frame(iso3=d$iso3[1],year=d$year[1],category='freedom',
 n_available=n,n_planned=3,minimum=3,score=if(n==3)mean(d$z) else NA,
 basket=paste(sort(d$code[is.finite(d$z)]),collapse=';'))
}))
write_csv(freedom,'data/clean/freedom_category_scores.csv')
# Happiness provider names require an explicit, reviewable name crosswalk; no fuzzy matches.
h<-as.data.frame(readxl::read_excel('data/raw/WHR26_Data_Figure_2.1.xlsx'))
aliases<-c('Congo'='COG','DR Congo'='COD','Egypt'='EGY','Gambia'='GMB',
 'Hong Kong SAR of China'='HKG','Iran'='IRN','Kyrgyzstan'='KGZ','Puerto Rico'='PRI',
 'Republic of Korea'='KOR','Republic of Moldova'='MDA','Slovakia'='SVK','Somalia'='SOM',
 'State of Palestine'='PSE','Swaziland'='SWZ','Syria'='SYR','Venezuela'='VEN','Yemen'='YEM')
# Unicode names written with explicit code points for portability on Windows locales.
aliases[c(paste0('C\u00f4te d\u2019Ivoire'),paste0('T\u00fcrkiye'))]<-c('CIV','TUR')
hcross<-data.frame(provider_country=sort(unique(h[['Country name']])),stringsAsFactors=FALSE)
hcross$iso3<-wb$iso3[match(hcross$provider_country,wb$name)]
for(n in names(aliases))hcross$iso3[hcross$provider_country==n]<-aliases[[n]]
hcross$iso3[!hcross$iso3 %in% wb$iso3]<-NA
hcross$match_status<-ifelse(is.na(hcross$iso3),'Excluded: distinct unit or outside WB reference','Reviewed exact name or explicit alias')
write_csv(hcross,'metadata/happiness_country_crosswalk.csv')
happy<-data.frame(iso3=hcross$iso3[match(h[['Country name']],hcross$provider_country)],
 provider_country=h[['Country name']],period_end_year=as.integer(h$Year),provider_rank=h$Rank,
 life_evaluation_score=h[['Life evaluation (3-year average)']],
 lower_95=h[['Lower whisker']],upper_95=h[['Upper whisker']])
happy<-happy[!is.na(happy$iso3),]
happy$name<-wb$name[match(happy$iso3,wb$iso3)]
happy$report_year<-happy$period_end_year+1L
happy$period_start_year<-ifelse(happy$period_end_year>=2012,happy$period_end_year-2L,NA_integer_)
happy$period_label<-ifelse(is.na(happy$period_start_year),
 'Early reporting period: start not assigned; consult original report',paste0(happy$period_start_year,'-',happy$period_end_year))
happy$measurement_note<-'Life evaluation on 0-10 ladder; published multi-year average, not an annual observation'
happy$primary_case<-happy$iso3 %in% cases$iso3
happy$reference_n<-NA_integer_;happy$reference_mean<-happy$reference_sd<-happy$z<-NA_real_
for(y in unique(happy$period_end_year)) {
 ids<-which(happy$period_end_year==y);x<-happy$life_evaluation_score[ids];n<-sum(is.finite(x))
 happy$reference_n[ids]<-n;happy$reference_mean[ids]<-mean(x,na.rm=TRUE);happy$reference_sd[ids]<-sd(x,na.rm=TRUE)
 if(n>=100)happy$z[ids]<-(x-mean(x,na.rm=TRUE))/sd(x,na.rm=TRUE)
}
stopifnot(!anyDuplicated(happy[c('iso3','period_end_year')]),all(cases$iso3 %in% happy$iso3))
write_csv(happy,'data/clean/happiness_period_scores.csv')
# Original country-year panel is preserved; happiness is deliberately not merged as annual data.
wide<-read.csv('data/clean/country_year_panel.csv')
expanded<-merge(wide,v[c('iso3','year',vars)],by=c('iso3','year'),all.x=TRUE)
write_csv(expanded,'data/clean/expanded_country_year_panel.csv')
cat('V-Dem rows:',nrow(v),'economies:',length(unique(v$iso3)),'; happiness periods:',nrow(happy),'economies:',length(unique(happy$iso3)),'\n')
# New-source catalog is separate: V-Dem codes must never be sent to the WDI API.
cb<-read.csv('metadata/vdem_selected_definitions.csv',stringsAsFactors=FALSE)
x<-data.frame(code=cb$tag,name=trimws(cb$name),category=ifelse(cb$tag %in% c('v2x_polyarchy','v2x_libdem'),'political_system','freedom'),
 role=ifelse(cb$tag %in% c('v2x_polyarchy','v2x_libdem'),'predictor','descriptive outcome'),direction=1,transform='none',
 composite=cb$tag %in% c('v2x_civlib','v2x_freexp_altinf','v2x_frassoc_thick'),unit='index from 0 to 1; higher means more',
 limitation='Expert-coded estimates; uncertainty retained; freedom and democracy share components, so not independent constructs')
write_csv(x,'metadata/additional_indicators.csv')
y<-data.frame(code=cb$tag,original_name=trimws(cb$name),original_definition=cb$question,source_organization='V-Dem Institute',
 source_id='v16',source_name='V-Dem Country-Year v16')
write_csv(y,'metadata/additional_source_definitions.csv')

