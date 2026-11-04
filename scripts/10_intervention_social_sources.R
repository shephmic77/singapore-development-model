source('scripts/text_encoding.R')
.libPaths(c(normalizePath('.R-library'),.libPaths()))
options(timeout=120)
write_csv<-function(x,path)write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')
# Each download is cached unchanged; only derived files are regenerated.
sources<-data.frame(file=c('IMFInvestmentandCapitalStockDataset2021.xlsx','PMR_Econwide_Indicator_2023-24_and_2018.xlsx',
 'PIP_20260922_2021_3USD_surveys.json','SingStat_M810361.json','SingStat_M810871.json'),
 url=c('https://infrastructuregovern.imf.org/content/dam/PIMA/Knowledge-Hub/dataset/IMFInvestmentandCapitalStockDataset2021.xlsx',
 'https://www.oecd.org/content/dam/oecd/en/topics/policy-sub-issues/product-market-regulation/PMR_Econwide_Indicator_2023-24_and_2018.xlsx',
 'https://api.worldbank.org/pip/v1/pip?country=all&year=all&povline=3&fill_gaps=false&ppp_version=2021&version=20260922_2021_01_02_PROD&format=json',
 'https://tablebuilder.singstat.gov.sg/api/table/tabledata/M810361',
 'https://tablebuilder.singstat.gov.sg/api/table/tabledata/M810871'),
 version=c('IMF May 2021 vintage: 1960-2019','OECD workbook downloaded November 2026; actual legal-reference dates retained',
 'PIP 20260922_2021_01_02_PROD; USD 3/day at 2021 PPP','SingStat M810361: provider update retained','SingStat M810871: provider update retained'),
 attribution=c('IMF Investment and Capital Stock Dataset 2021','OECD Product Market Regulation; OECD/OECD-WBG/OECD-ADB provider labels retained',
 'World Bank Poverty and Inequality Platform; 22 September 2026 release','Singapore Department of Statistics','Singapore Department of Statistics'))
sources<-rbind(sources,data.frame(file='Hong_Kong_2021_household_income_report.pdf',
 url='https://www.census2021.gov.hk/doc/pub/21c-Household-Income.pdf',version='2021 Population Census thematic report, published May 2023; Table 6.1',
 attribution='Hong Kong Census and Statistics Department; six values transcribed with source page and separate population definitions'))
for(i in seq_len(nrow(sources))) {
 p<-file.path('data/raw',sources$file[i]);if(!file.exists(p)){tmp<-paste0(p,'.part');download.file(sources$url[i],tmp,mode='wb',quiet=TRUE);stopifnot(file.rename(tmp,p))}
}
sources$file<-file.path('data/raw',sources$file)
sources$download_file_time_utc<-format(file.info(sources$file)$mtime,tz='UTC',usetz=TRUE)
sources$time_note<-'Timestamp recorded from local downloaded-file modification time'
sources$md5<-unname(tools::md5sum(sources$file))
write_csv(sources,'metadata/fiscal_social_source_manifest.csv')
wb<-read.csv('metadata/countries.csv');cases<-read.csv('metadata/primary_cases.csv')
# IMF numerator and denominator come from the SAME nominal-currency dataset.
imf<-as.data.frame(readxl::read_excel(sources$file[1],sheet='Dataset'))
imf_def<-as.data.frame(readxl::read_excel(sources$file[1],sheet='Definitions',col_names=FALSE,.name_repair='minimal',col_types='text'))
names(imf_def)<-c('source_variable','original_definition');write_csv(imf_def,'metadata/imf_investment_definitions.csv')
cross<-unique(imf[c('isocode','country')]);cross$iso3<-ifelse(cross$isocode %in% wb$iso3,cross$isocode,NA)
cross$match_status<-ifelse(is.na(cross$iso3),'Excluded: code outside WB reference','Exact provider code; provider name retained')
write_csv(cross,'metadata/imf_country_crosswalk.csv')
imf$iso3<-cross$iso3[match(imf$isocode,cross$isocode)]
imf<-imf[!is.na(imf$iso3) & imf$year>=1965,]
for(col in setdiff(names(imf),c('isocode','country','income','iso3')))imf[[col]]<-suppressWarnings(as.numeric(imf[[col]]))
imf$government_investment_pct_gdp<-ifelse(is.finite(imf$igov_n) & is.finite(imf$GDP_n) & imf$GDP_n>0 & imf$igov_n>=0,100*imf$igov_n/imf$GDP_n,NA)
imf$name<-wb$name[match(imf$iso3,wb$iso3)];imf$primary_case<-imf$iso3 %in% cases$iso3
imf$measurement_note<-'General-government gross fixed capital formation / same-source nominal GDP; NOT total state intervention or SOE ownership'
imf$source_vintage<-'IMF May 2021; no observations after 2019 in this workbook'
stopifnot(!anyDuplicated(imf[c('iso3','year')]))
write_csv(imf,'data/clean/imf_public_investment.csv')
# PMR scores are periodic assessments with actual legal dates; never forward-filled.
pmr<-list();headers<-list()
for(sheet in c('PMR_Econwide_2018','PMR_Econwide_2023-24')) {
 d<-as.data.frame(readxl::read_excel(sources$file[2],sheet=sheet,col_names=FALSE,.name_repair='minimal',col_types='text'))
 headers[[sheet]]<-data.frame(sheet=sheet,column_number=seq_len(ncol(d)),provider_header=unlist(d[4,],use.names=FALSE))
 good<-!is.na(d[[1]]) & grepl('^[A-Z]{3}$',d[[1]])
 x<-data.frame(iso3=d[[1]][good],provider_country=d[[2]][good],assessment_wave=sheet,
  provider=d[[4]][good],legal_reference_date=as.character(as.Date(as.numeric(d[[5]][good]),origin='1899-12-30')),
  state_involvement_score=as.numeric(d[[7]][good]),public_ownership_distortion_score=as.numeric(d[[9]][good]))
 x$legal_reference_year<-as.integer(substr(x$legal_reference_date,1,4))
 x$in_main_annual_window<-x$legal_reference_year<=2024
 x$interpretation<-'Regulatory distortions associated with public ownership; not the share of the economy owned by government'
 x$unit<-'PMR indicator scale 0-6; higher means more restrictive/distortionary regulation, not automatically more developmental intervention'
 pmr[[sheet]]<-x
}
pmr<-do.call(rbind,pmr);write_csv(do.call(rbind,headers),'metadata/pmr_workbook_headers.csv')
write_csv(pmr,'data/clean/oecd_public_ownership_assessments.csv')
stopifnot(!anyDuplicated(pmr[c('iso3','assessment_wave')]))
# PIP: preserve all reporting concepts before creating a strict national subset.
pip<-jsonlite::fromJSON(sources$file[3]);pip$iso3<-pip$country_code;pip$year<-pip$reporting_year
pip<-pip[pip$iso3 %in% wb$iso3 & pip$year>=1965 & pip$year<=2025,]
pip$gini_0_100<-100*pip$gini;pip$poverty_3usd_pct<-100*pip$headcount
pip$bottom_40_share_pct<-100*rowSums(pip[c('decile1','decile2','decile3','decile4')],na.rm=FALSE)
pip$top_10_share_pct<-100*pip$decile10
pip$ppp_base_year<-2021L;pip$source_version<-'20260922_2021_01_02_PROD'
pip$primary_case<-pip$iso3 %in% cases$iso3
pip$national_eligible<-pip$reporting_level=='national' & pip$survey_coverage=='national' & !is.na(pip$is_interpolated) & !pip$is_interpolated & pip$estimation_type=='survey'
pip$comparability_block<-ifelse(!is.na(pip$survey_comparability) & !is.na(pip$comparable_spell) & nzchar(pip$comparable_spell),
 paste(pip$iso3,pip$welfare_type,pip$reporting_level,pip$survey_coverage,pip$survey_comparability,pip$comparable_spell,sep=' | '),NA_character_)
pip$measurement_note<-'Survey estimates; income and consumption are different concepts. Provider comparability IDs indicate within-country spells, not global quality scores.'
# Keep the analysis catalog focused. The unchanged raw JSON retains other provider statistics.
pip<-pip[setdiff(names(pip),c('region_name','region_code','poverty_gap','poverty_severity','watts','mld','polarization','cpi','ppp','reporting_pop','reporting_gdp','reporting_pce','spl','spr','pg','estimate_type'))]
write_csv(pip,'data/clean/pip_survey_social_outcomes.csv')
national<-pip[!is.na(pip$national_eligible) & pip$national_eligible,]
stopifnot(!anyDuplicated(national[c('iso3','year','welfare_type')]))
write_csv(national,'data/clean/pip_national_social_outcomes.csv')
# Local Singapore case study: retain all Gini definitions; do not splice them into PIP.
sg<-list();sgmetadata<-list()
for(id in c('M810361','M810871')) {
 data<-jsonlite::fromJSON(paste0('data/raw/SingStat_',id,'.json'))$Data
 sgmetadata[[id]]<-data.frame(table_id=id,title=data$title,provider_update_date=data$dataLastUpdated,provider_generation_date=data$dateGenerated,
  population_definition=data$footnote)
 r<-data$row
 for(i in which(grepl('Gini',r$rowText,ignore.case=TRUE))) {
  columns<-r$columns[[i]];label<-r$rowText[i]
  scale<-if(grepl('Modified OECD',label,ignore.case=TRUE))'Modified OECD equivalence scale' else if(grepl('Square Root',label,ignore.case=TRUE))'Square-root equivalence scale' else 'Per household member'
  treatment<-if(grepl('After',label,ignore.case=TRUE))'After government transfers and taxes' else if(grepl('Including Regular Government Contributions',label,ignore.case=TRUE))'Including regular government contributions' else 'Before government transfers and taxes'
  sg[[length(sg)+1]]<-data.frame(iso3='SGP',year=as.integer(columns$key),table_id=id,series_id=r$seriesNo[i],
   original_series_name=label,gini_0_1=suppressWarnings(as.numeric(columns$value)),
   income_concept=if(id=='M810361')'Employment income including employer CPF' else 'Market income: employment and non-employment',
   household_population=if(id=='M810361')'Resident employed households' else 'Resident households',
   equivalence_scale=scale,tax_transfer_treatment=treatment,provider_update_date=data$dataLastUpdated,series_footnote=r$footnote[i])
 }
}
sg<-do.call(rbind,sg);sg$gini_0_100<-100*sg$gini_0_1
write_csv(sg,'data/clean/singapore_gini_definitions.csv');write_csv(do.call(rbind,sgmetadata),'metadata/singapore_gini_table_definitions.csv')
# Keep an explicit row for every selected case, including absence and urban-only coverage.
coverage<-list()
for(iso in cases$iso3) {
 a<-imf[imf$iso3==iso & is.finite(imf$government_investment_pct_gdp),]
 b<-pmr[pmr$iso3==iso,];c<-pip[pip$iso3==iso,];n<-national[national$iso3==iso,]
 coverage[[length(coverage)+1]]<-data.frame(iso3=iso,name=cases$name[match(iso,cases$iso3)],
  public_investment_years=nrow(a),public_investment_last_year=if(nrow(a))max(a$year) else NA,
  pmr_assessments=nrow(b),pmr_legal_dates=if(nrow(b))paste(b$legal_reference_date,collapse='; ') else 'Not in downloaded assessments',
  pip_all_survey_rows=nrow(c),pip_national_survey_rows=nrow(n),pip_welfare_types=paste(sort(unique(c$welfare_type)),collapse='; '),
  pip_status=if(!nrow(c))'Not covered in this PIP snapshot' else if(!nrow(n))'Only non-national coverage; excluded from national models' else 'Nationally labeled survey observations available',
  local_gini_status=if(iso=='SGP')'Official SingStat series collected separately; not pooled with PIP' else if(iso=='HKG')'Official Census Table 6.1: six verified case-study values; not pooled with PIP' else 'Use PIP concept and coverage labels')
}
write_csv(do.call(rbind,coverage),'outputs/tables/intervention_social_case_coverage.csv')
# Empirical source coverage and concept-separated references.
source_coverage<-aggregate(is.finite(government_investment_pct_gdp)~year,imf,sum)
names(source_coverage)[2]<-'n_observed';write_csv(source_coverage,'outputs/tables/public_investment_coverage_by_year.csv')
refs<-do.call(rbind,lapply(split(national,interaction(national$year,national$welfare_type,drop=TRUE)),function(d)
 data.frame(year=d$year[1],welfare_type=d$welfare_type[1],n_observed=nrow(d),
  gini_mean_0_100=mean(d$gini_0_100,na.rm=TRUE),poverty_mean_pct=mean(d$poverty_3usd_pct,na.rm=TRUE),
  definition='Survey-year, nationally labeled reporting; income and consumption benchmarked separately; no missing years filled')))
write_csv(refs,'outputs/tables/social_references_by_welfare_type.csv')
write_csv(data.frame(source=c('IMF public investment','OECD public ownership','PIP survey distribution','Singapore local inequality'),
 decision=c('Use as a narrow fiscal-investment measure, not total intervention','Descriptive periodic assessments only; dates and missing cases prevent an annual Singapore-model predictor',
 'Use national survey records, separate welfare types and preserve comparability blocks','Separate case-study series; retain population, tax and equivalence definitions'),
 limitation=c('2021 vintage ends in 2019; general government excludes many public corporations and industrial-policy tools',
 'Singapore absent; selected cases have mixed legal-reference dates including years after 2024',
 'Singapore/Hong Kong absent; Argentina urban-only; country-level harmonization is incomplete',
 'Employment-income and market-income series have different populations; do not splice or pool by label alone')),
 'outputs/tables/intervention_social_measure_decisions.csv')
cat('Intervention/social source collection and concept audit complete.\n')

# Six verified census values are explicit curated input, not invented annual observations.
hk<-read.csv('metadata/hong_kong_gini_transcription.csv')
hk$gini_0_100<-100*hk$gini_0_1
hk$income_concept<-'Per-person monthly household income after tax and social benefits, including in-kind benefits and one-off relief'
hk$source_url<-'https://www.census2021.gov.hk/doc/pub/21c-Household-Income.pdf'
hk$comparison_note<-'Separate local case study; no annual interpolation or automatic pooling with Singapore/PIP'
write_csv(hk,'data/clean/hong_kong_census_gini.csv')
# Same-year source differences are visible; equality of values is not proof of identical definitions.
wdi<-read.csv('data/clean/international_long.csv')
wdi<-wdi[wdi$code=='SI.POV.GINI' & is.finite(wdi$value),c('iso3','year','value')]
names(wdi)[3]<-'wdi_gini_0_100'
audit<-merge(wdi,pip[c('iso3','year','welfare_type','reporting_level','survey_coverage','gini_0_100','source_version')],by=c('iso3','year'))
audit$wdi_minus_pip<-audit$wdi_gini_0_100-audit$gini_0_100
audit$interpretation<-'Same-year candidate comparison only; source vintages or welfare definitions may differ; no automatic substitution'
write_csv(audit,'outputs/tables/wdi_pip_gini_same_year_audit.csv')

