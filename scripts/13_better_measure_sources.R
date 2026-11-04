source('scripts/text_encoding.R')
.libPaths(c(normalizePath('.R-library'),.libPaths()))
options(timeout=120)
write_csv<-function(x,path)write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')
sources<-data.frame(file=c('swiid9_92.zip','HDR25_Composite_indices_complete_time_series.csv','HDR25_Composite_indices_metadata.xlsx'),
 url=c('https://dataverse.harvard.edu/api/access/datafile/13657070',
 'https://hdr.undp.org/sites/default/files/2025_HDR/HDR25_Composite_indices_complete_time_series.csv',
 'https://hdr.undp.org/sites/default/files/2025_HDR/HDR25_Composite_indices_metadata.xlsx'),
 version=c('SWIID 9.92, April 2026; Harvard Dataverse release 16.0, file 13657070','UNDP Human Development Report 2025; 1990-2023 series','UNDP Human Development Report 2025 metadata'),
 attribution=c('Solt (2020), SWIID 9.92, April 2026; DOI 10.7910/DVN/LM4OWF','UNDP Human Development Report Office, HDR 2025','UNDP Human Development Report Office, HDR 2025'))
for(i in seq_len(nrow(sources))) {
 p<-file.path('data/raw',sources$file[i]);if(!file.exists(p)){tmp<-paste0(p,'.part');download.file(sources$url[i],tmp,mode='wb',quiet=TRUE);stopifnot(file.rename(tmp,p))}
}
stopifnot(unname(tools::md5sum('data/raw/swiid9_92.zip'))=='29fea15aa2dc73d757cf1775cf99e9c0')
# Extract each immutable archive member once to the archive's own version folder.
listing<-unzip('data/raw/swiid9_92.zip',list=TRUE)
for(file in listing$Name[!grepl('/$',listing$Name)])if(!file.exists(file.path('data/raw',file)))unzip('data/raw/swiid9_92.zip',files=file,exdir='data/raw')
sources$file<-file.path('data/raw',sources$file);sources$md5<-unname(tools::md5sum(sources$file))
sources$download_file_time_utc<-format(file.info(sources$file)$mtime,tz='UTC',usetz=TRUE)
sources$time_note<-'Recorded from local downloaded-file modification time'
write_csv(sources,'metadata/ownership_social_source_manifest.csv')
wb<-read.csv('metadata/countries.csv');cases<-read.csv('metadata/primary_cases.csv')
# V-Dem: a distinct ownership/direct-control concept, not public spending.
e<-new.env();load('data/raw/v16_vdem.RData',e)
vars<-c('country_name','country_text_id','year','v2clstown','v2clstown_codelow','v2clstown_codehigh','v2clstown_sd',
 'v2clstown_osp','v2clstown_osp_codelow','v2clstown_osp_codehigh','v2clstown_osp_sd','v2clstown_nr')
v<-e$vdem[e$vdem$year>=1965 & e$vdem$year<=2025,vars];rm(e);gc(verbose=FALSE)
cross<-read.csv('metadata/vdem_country_crosswalk.csv',na.strings=c('','NA'))
v$iso3<-cross$iso3[match(v$country_text_id,cross$country_text_id)];v<-v[!is.na(v$iso3),]
v$name<-wb$name[match(v$iso3,wb$iso3)];v$primary_case<-v$iso3 %in% cases$iso3
v$ownership_control_0_4<-4-v$v2clstown_osp
v$ownership_lower_bound<-4-v$v2clstown_osp_codehigh
v$ownership_upper_bound<-4-v$v2clstown_osp_codelow
v$ownership_latent_reversed<- -v$v2clstown
v$measurement_note<-'Expert-coded state ownership/direct control of important sectors. Higher reversed score means more control; not asset share or better development.'
v$evidence_type<-'V-Dem model-based expert assessment; provider point uncertainty retained'
v$source_version<-'V-Dem Country-Year v16'
write_csv(v,'data/clean/state_ownership_control.csv')
b<-new.env();load('data/raw/v16_codebook.RData',b)
write_csv(b$codebook[b$codebook$tag=='v2clstown',],'metadata/state_ownership_definition.csv')
write_csv(data.frame(original_response=0:4,reversed_control_category=4:0,
 interpretation=c('Virtually all valuable capital under state ownership/direct control','Most valuable capital under state ownership/direct control',
 'Many sectors under state ownership/direct control; other sectors relatively free','Some valuable capital under state ownership/direct control; most relatively free','Very little valuable capital under state ownership/direct control')),
 'metadata/state_ownership_response_guide.csv')
# SWIID uses a standardized income concept but remains provider-modeled, not raw survey observations.
s<-read.csv('data/raw/swiid9_92/swiid9_92_summary.csv',stringsAsFactors=FALSE)
alias<-c('Bahamas'='BHS','Brunei'='BRN','Cape Verde'='CPV','Congo-Brazzaville'='COG','Congo-Kinshasa'='COD',
 'Czech Republic'='CZE','Egypt'='EGY','Gambia'='GMB','Hong Kong'='HKG','Iran'='IRN','Korea'='KOR','Kyrgyzstan'='KGZ',
 'Laos'='LAO','Micronesia'='FSM','Nauru'='NRU','Puerto Rico'='PRI','Russia'='RUS','Slovakia'='SVK','Somalia'='SOM',
 'St. Vincent and Grenadines'='VCT','Syria'='SYR','Turkey'='TUR','Venezuela'='VEN','Vietnam'='VNM','Yemen'='YEM')
alias[c('C\u00f4te d\u0027Ivoire','S\u00e3o Tom\u00e9 and Pr\u00edncipe')]<-c('CIV','STP')
scross<-data.frame(provider_country=sort(unique(s$country)),stringsAsFactors=FALSE)
scross$iso3<-wb$iso3[match(scross$provider_country,wb$name)]
for(n in names(alias))scross$iso3[scross$provider_country==n]<-alias[[n]]
scross$iso3[!scross$iso3 %in% wb$iso3]<-NA
scross$match_status<-ifelse(is.na(scross$iso3),'Excluded: historical/different unit, outside reference, or scope not verified','Exact name or explicit reviewed alias; pre-1991 territorial continuity not certified')
write_csv(scross,'metadata/swiid_country_crosswalk.csv')
s$iso3<-scross$iso3[match(s$country,scross$provider_country)];s<-s[!is.na(s$iso3) & s$year>=1965 & s$year<=2025,]
s$name<-wb$name[match(s$iso3,wb$iso3)];s$primary_case<-s$iso3 %in% cases$iso3
s$disposable_lower95<-s$gini_disp-1.96*s$gini_disp_se;s$disposable_upper95<-s$gini_disp+1.96*s$gini_disp_se
s$market_lower95<-s$gini_mkt-1.96*s$gini_mkt_se;s$market_upper95<-s$gini_mkt+1.96*s$gini_mkt_se
s$measurement_note<-'Provider-standardized square-root-equivalized household income inequality, Gini 0-100; disposable=after taxes/transfers, market=before'
s$evidence_type<-'SWIID provider-modeled/standardized estimate; not a new direct survey observation'
s$uncertainty_note<-'Approximate 95 percent provider uncertainty band: mean +/- 1.96 standard error; not cross-country sampling uncertainty'
s$source_version<-'SWIID 9.92, April 2026; published summary CSV'
write_csv(s,'data/clean/swiid_standardized_income_inequality.csv')
# Quality gate: independently inspect supplied formats; never guess a normalization for analysis.
e<-new.env();load('data/raw/swiid9_92/swiid9_92.rda',e)
reported<-as.data.frame(e$swiid_summary)
rkeys<-paste(e$swiid[[1]]$country,e$swiid[[1]]$year);j<-match(rkeys,paste(reported$country,reported$year));stopifnot(!anyNA(j))
draw_audit<-list()
stata<-as.data.frame(haven::read_dta('data/raw/swiid9_92/swiid9_92.dta',encoding='UTF-8'))
sj<-match(paste(stata$country,stata$year),paste(reported$country,reported$year));stopifnot(!anyNA(sj))
for(var in c('gini_disp','gini_mkt')) {
 rm<-sapply(e$swiid,function(x)x[[var]])
 # Division by 100 is tested ONLY as a diagnostic, not used to create an analysis dataset.
 draw_audit[[paste0('R_',var)]]<-data.frame(format='R supplied draws',variable=var,n_draws=ncol(rm),
 raw_min=min(rm,na.rm=TRUE),raw_max=max(rm,na.rm=TRUE),
 max_gap_to_summary=max(abs(rowMeans(rm)-reported[[var]][j]),na.rm=TRUE),
 max_gap_after_diagnostic_division100=max(abs(rowMeans(rm)/100-reported[[var]][j]),na.rm=TRUE),
 decision='Withheld from regression: supplied scale and summary concordance not validated')
 cols<-grep(paste0('^_[0-9]+_',var,'$'),names(stata),value=TRUE);sm<-as.matrix(stata[cols])
 draw_audit[[paste0('Stata_',var)]]<-data.frame(format='Stata supplied draws',variable=var,n_draws=ncol(sm),
 raw_min=min(sm,na.rm=TRUE),raw_max=max(sm,na.rm=TRUE),max_gap_to_summary=max(abs(rowMeans(sm)-reported[[var]][sj]),na.rm=TRUE),
 max_gap_after_diagnostic_division100=NA_real_,decision='Withheld from regression: unresolved discrepancies against published summary; not asserted to be a provider error')
}
write_csv(do.call(rbind,draw_audit),'outputs/tables/swiid_draw_format_audit.csv')
rm(e,stata);gc(verbose=FALSE)
# UNDP: only annual GII values, never the rank column or regional aggregates.
u<-read.csv('data/raw/HDR25_Composite_indices_complete_time_series.csv',check.names=FALSE,fileEncoding='latin1')
ucross<-u[c('iso3','country')];ucross$included<-ucross$iso3 %in% wb$iso3
write_csv(ucross,'metadata/undp_country_crosswalk.csv')
u<-u[u$iso3 %in% wb$iso3,];cols<-grep('^gii_[0-9]{4}$',names(u),value=TRUE)
gii<-do.call(rbind,lapply(cols,function(col)data.frame(iso3=u$iso3,provider_country=u$country,year=as.integer(sub('gii_','',col)),gender_inequality_index=as.numeric(u[[col]]))))
gii$name<-wb$name[match(gii$iso3,wb$iso3)];gii$primary_case<-gii$iso3 %in% cases$iso3
gii$evidence_type<-'UNDP published composite using reproductive health, empowerment and labor-market components; not all components are independent annual surveys'
gii$measurement_note<-'Index 0-1; lower means less measured gender inequality; not a complete social-outcome measure'
gii$source_version<-'UNDP HDR 2025; time-series data through 2023'
gii$gender_relative_z<-NA_real_;gii$reference_n<-NA_integer_;gii_refs<-list()
for(y in sort(unique(gii$year))) {
 ids<-which(gii$year==y);x<-gii$gender_inequality_index[ids];n<-sum(is.finite(x));m<-mean(x,na.rm=TRUE);sdev<-sd(x,na.rm=TRUE)
 gii$reference_n[ids]<-n;if(n>=100 && is.finite(sdev) && sdev>0)gii$gender_relative_z[ids]<- -(x-m)/sdev
 gii_refs[[length(gii_refs)+1]]<-data.frame(year=y,n_observed=n,reference_mean=m,reference_sd=sdev,eligible=n>=100 && is.finite(sdev) && sdev>0)
}
write_csv(do.call(rbind,gii_refs),'outputs/tables/gender_inequality_reference_by_year.csv')
write_csv(gii,'data/clean/undp_gender_inequality.csv')
for(sheet in readxl::excel_sheets('data/raw/HDR25_Composite_indices_metadata.xlsx')) {
 m<-as.data.frame(readxl::read_excel('data/raw/HDR25_Composite_indices_metadata.xlsx',sheet=sheet))
 write_csv(m,paste0('metadata/undp_',gsub(' ','_',sheet),'.csv'))
}
# One row per case makes absence and last available year unambiguous.
coverage<-do.call(rbind,lapply(cases$iso3,function(iso) {
 a<-v[v$iso3==iso & is.finite(v$ownership_control_0_4),];b<-s[s$iso3==iso & is.finite(s$gini_disp),];c<-gii[gii$iso3==iso & is.finite(gii$gender_inequality_index),]
 data.frame(iso3=iso,name=cases$name[match(iso,cases$iso3)],ownership_years=nrow(a),ownership_last_year=if(nrow(a))max(a$year) else NA,
 swiid_years=nrow(b),swiid_first_year=if(nrow(b))min(b$year) else NA,swiid_last_year=if(nrow(b))max(b$year) else NA,
 gii_years=nrow(c),gii_last_year=if(nrow(c))max(c$year) else NA,
 gii_status=if(nrow(c))'Provider values available' else 'No numeric value in this UNDP release; not imputed')
}))
write_csv(coverage,'outputs/tables/ownership_social_case_coverage.csv')
common<-Reduce(intersect,lapply(cases$iso3,function(iso)s$year[s$iso3==iso & is.finite(s$gini_disp) & is.finite(s$gini_mkt)]))
common<-common[common>=2000 & common<=2024]
if(length(common))write_csv(s[s$primary_case & s$year==max(common),],'outputs/tables/swiid_same_year_case_comparison.csv')
refs<-do.call(rbind,lapply(split(s,s$year),function(d)data.frame(year=d$year[1],n_observed=nrow(d),
 disposable_gini_mean=mean(d$gini_disp),disposable_gini_sd=sd(d$gini_disp),market_gini_mean=mean(d$gini_mkt),market_gini_sd=sd(d$gini_mkt),
 definition='Unweighted matched-economy mean of provider-standardized estimates; same-year available countries; no direct-survey claim')))
write_csv(refs,'outputs/tables/swiid_same_year_references.csv')
write_csv(data.frame(candidate=c('V-Dem state ownership/direct control','Fraser state-ownership component','SWIID published summaries','SWIID supplied uncertainty draws','UNDP Gender Inequality Index','WIID Companion corrected September 2026'),
 decision=c('Accepted as a distinct expert-assessed ownership component, with latent-scale sensitivity','Not independent corroboration: documented source is V-Dem',
 'Accepted for descriptive standardized-income comparisons with provider uncertainty','Regression withheld pending format/summary concordance resolution',
 'Accepted as a separate gender dimension; no universal social composite','Not imported: official file download returned HTTP 403'),
 limit=c('Not a percentage of government-owned assets and not all intervention tools','Would duplicate the existing source rather than supply independent ownership data',
 'Provider-modeled estimates, residual incomparability and different last available years','No guessed conversion or synthetic replacement draws',
 'Hong Kong missing; overlaps some health/education domains; composite estimation and source lags','No bypass attempted; corrected release identified and documented')),
 'outputs/tables/better_measure_source_decisions.csv')
cat('Ownership, standardized-inequality summaries and gender data updated.\n')



