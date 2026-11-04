source('scripts/text_encoding.R')
.libPaths(c(normalizePath('.R-library'),.libPaths()))
write_csv<-function(x,p)write.csv(x,p,row.names=FALSE,na='',fileEncoding='UTF-8')
url<-'https://ddh-openapi.worldbank.org/resources/DR0095334/download'
path<-'data/raw/World_Bank_historical_income_classifications.xlsx'
if(!file.exists(path)) {tmp<-paste0(path,'.part');download.file(url,tmp,quiet=TRUE,mode='wb');stopifnot(file.rename(tmp,path))}
write_csv(data.frame(file=path,url=url,version='Official workbook as downloaded; fiscal labels retained',
 download_file_time_utc=format(file.info(path)$mtime,tz='UTC',usetz=TRUE),md5=unname(tools::md5sum(path)),
 attribution='World Bank historical analytical income classifications; public WDI supporting data',
 time_note='Local downloaded-file modification time'), 'metadata/historical_classification_manifest.csv')
d<-as.data.frame(readxl::read_excel(path,sheet='Country Analytical History',col_names=FALSE,.name_repair='minimal',col_types='text'))
wb<-read.csv('metadata/countries.csv');rows<-which(!is.na(d[[1]]) & d[[1]] %in% wb$iso3)
columns<-which(grepl('^FY[0-9]{2}$',as.character(d[5,])))
classes<-list()
for(j in columns) {
 data_year<-as.integer(d[6,j]);fy<-data_year+2L
 # FY2025 runs July 2024-June 2025. Assign it explicitly to calendar-year July 1, 2024.
 stopifnot(paste0('FY',substr(as.character(fy),3,4))==d[5,j])
 raw<-d[rows,j];group<-c(L='Low income',LM='Lower middle income',UM='Upper middle income',H='High income')[raw]
 classes[[length(classes)+1]]<-data.frame(iso3=d[rows,1],provider_country=d[rows,2],year=fy-1L,
  fiscal_year=fy,gni_data_year=data_year,classification_code=raw,historical_income_group=unname(group),
  assignment_rule='Classification in force on July 1 of observation year; based on previous-year Atlas GNI',
  classification_note=ifelse(raw=='LM*','Excluded: retrospective combined-Yemen classification',ifelse(is.na(group),'No usable classification','Published classification')))
}
classes<-do.call(rbind,classes);stopifnot(!anyDuplicated(classes[c('iso3','year')]))
write_csv(classes,'data/clean/historical_income_classifications.csv')
p<-read.csv('data/clean/international_long.csv')
p<-merge(p,classes[c('iso3','year','historical_income_group')],by=c('iso3','year'),all.x=TRUE)
refs<-list()
# Raw measurements retain units. No small-peer-group z-score is passed off as a global score.
for(type in c('historical_income_group','region')) {
 valid<-p[!is.na(p[[type]]) & nzchar(p[[type]]),]
 for(d in split(valid,interaction(valid$code,valid$year,valid[[type]],drop=TRUE))) {
  x<-d$value[is.finite(d$value)];group<-d[[type]][1];year<-d$year[1]
  n_members<-if(type=='region')sum(wb$region==group) else sum(classes$year==year & classes$historical_income_group==group,na.rm=TRUE)
  refs[[length(refs)+1]]<-data.frame(code=d$code[1],year=year,peer_type=type,peer_group=group,
   n_reference=n_members,n_observed=length(x),raw_mean=if(length(x))mean(x) else NA_real_,raw_sd=if(length(x)>1)sd(x) else NA_real_)
 }
}
refs<-do.call(rbind,refs);write_csv(refs,'outputs/tables/historical_and_regional_references.csv')
sg<-p[p$iso3=='SGP',c('year','code','value','historical_income_group','region')]
comparison<-merge(sg,refs,by=c('year','code'))
comparison<-comparison[(comparison$peer_type=='historical_income_group' & comparison$peer_group==comparison$historical_income_group) |
 (comparison$peer_type=='region' & comparison$peer_group==comparison$region),]
comparison$singapore_minus_peer_mean<-comparison$value-comparison$raw_mean
comparison$interpretation<-'Difference in original measurement units; whether positive is desirable depends on the indicator'
write_csv(comparison,'outputs/tables/singapore_peer_comparisons.csv')
# Balanced reference: a separate, explicit common-country sample within each indicator, 2000-2024.
balanced<-list()
for(code in unique(p$code)) {
 d<-p[p$code==code & p$year>=2000 & p$year<=2024,]
 n<-tapply(is.finite(d$value),d$iso3,sum);ids<-names(n)[n==25]
 for(year in 2000:2024) {
  x<-d$value[d$iso3 %in% ids & d$year==year];x<-x[is.finite(x)]
  balanced[[length(balanced)+1]]<-data.frame(code=code,year=year,n_reference=length(ids),n_observed=length(x),
    raw_mean=if(length(x))mean(x) else NA_real_,raw_sd=if(length(x)>1)sd(x) else NA_real_,
    definition='Same economies observed in every year 2000-2024 for this indicator; not representative of all economies')
 }
}
write_csv(do.call(rbind,balanced),'outputs/tables/balanced_reference_2000_2024.csv')
# One readable chart shows the distinction between global, historical-income and geographic peers.
code<-'SP.DYN.LE00.IN'
sglife<-p[p$iso3=='SGP' & p$code==code & p$year>=1988 & p$year<=2024,];sglife<-sglife[order(sglife$year),]
global<-aggregate(value~year,p[p$code==code & p$year>=1988 & p$year<=2024,],mean)
high<-refs[refs$code==code & refs$peer_type=='historical_income_group' & refs$peer_group=='High income' & refs$year<=2024,];high<-high[order(high$year),]
region<-refs[refs$code==code & refs$peer_type=='region' & refs$peer_group==wb$region[wb$iso3=='SGP'] & refs$year>=1988 & refs$year<=2024,];region<-region[order(region$year),]
png('outputs/figures/singapore_life_expectancy_peers.png',width=1500,height=1000,res=140)
par(mar=c(5,5,5,2),oma=c(3,0,0,0))
plot(sglife$year,sglife$value,type='l',lwd=3,col='#B33B35',xlab='Calendar year',ylab='Life expectancy at birth (years)',
 ylim=range(c(sglife$value,global$value,high$raw_mean,region$raw_mean),na.rm=TRUE),main='Singapore life expectancy: three different reference groups')
lines(global$year,global$value,col='#666666',lty=2,lwd=2)
lines(high$year,high$raw_mean,col='#176B8A',lty=3,lwd=2)
lines(region$year,region$raw_mean,col='#447744',lty=4,lwd=2)
legend('bottomright',c('Singapore','All available reference economies','Historically high income (July classification)','East Asia and Pacific (current region definition)'),col=c('#B33B35','#666666','#176B8A','#447744'),lty=1:4,lwd=c(3,2,2,2),bty='n',cex=.8)
mtext('Income-group membership changes with its published historical classification; reference means are unweighted.',side=3,line=.8,cex=.8)
mtext('Source: World Bank WDI and historical income classifications. Missing observations change group coverage; counts are exported.',side=1,outer=TRUE,line=1,cex=.8)
dev.off()
cat('Historical income classifications and regional/balanced benchmarks updated.\n')
