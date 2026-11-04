source('scripts/text_encoding.R')
# Run from the project root. Raw downloads are cached and never overwritten.
.libPaths(c(normalizePath('.R-library'), .libPaths()))
stopifnot(requireNamespace('jsonlite', quietly=TRUE))
options(timeout=120)
START <- 1965L; END <- 2025L; MIN_REFERENCE <- 100L
catalog <- read.csv('metadata/indicators.csv', stringsAsFactors=FALSE)
cases <- read.csv('metadata/primary_cases.csv', stringsAsFactors=FALSE)
write_csv <- function(x, path) write.csv(x, path, row.names=FALSE, na='')
get_json <- function(endpoint, key) {
  path <- file.path('data/raw', paste0(key, '.json'))
  url <- paste0('https://api.worldbank.org/v2/', endpoint,
                if(grepl('?', endpoint, fixed=TRUE)) '&' else '?', 'format=json&per_page=20000')
  if(!file.exists(path)) {
    temp <- paste0(path, '.part')
    download.file(url, temp, quiet=TRUE, mode='wb')
    parsed <- jsonlite::fromJSON(temp)
    if(length(parsed)!=2 || is.null(parsed[[2]])) stop('Invalid API response: ', key)
    if(!is.null(parsed[[1]]$pages) && parsed[[1]]$pages>1) stop('Pagination needed: ', key)
    stopifnot(file.rename(temp, path))
    log <- data.frame(file=path, url=url, retrieved_utc=format(Sys.time(), tz='UTC', usetz=TRUE),
                      md5=unname(tools::md5sum(path)))
    write.table(log, 'data/raw/manifest.csv', sep=',', row.names=FALSE,
                col.names=!file.exists('data/raw/manifest.csv'), append=file.exists('data/raw/manifest.csv'))
    Sys.sleep(0.3)
  }
  jsonlite::fromJSON(path)
}
country <- get_json('country', 'countries')[[2]]
country <- country[country$region$id!='NA' & country$region$value!='Aggregates', ]
countries <- data.frame(iso3=country$id, name=country$name, region=country$region$value,
                        current_income_group=country$incomeLevel$value)
# WB reference includes separately reported economies; never call it sovereign-only.
write_csv(countries, 'metadata/countries.csv')
stopifnot(all(cases$iso3 %in% countries$iso3))
rows <- list(); failures <- list(); definitions <- list()
for(i in seq_len(nrow(catalog))) {
  code <- catalog$code[i]; message('Collecting ', code)
  tryCatch({
    meta <- get_json(paste0('indicator/', code), paste0('metadata_',code))[[2]]
    definitions[[code]] <- data.frame(code=code, original_name=meta$name[1],
      original_definition=meta$sourceNote[1], source_organization=meta$sourceOrganization[1],
      source_id=meta$source$id[1], source_name=meta$source$value[1])
    dat <- get_json(paste0('country/all/indicator/',code,'?date=',START,':',END), code)
    d <- dat[[2]]
    rows[[code]] <- data.frame(iso3=d$countryiso3code, year=as.integer(d$date),
      code=code, value=as.numeric(d$value), source_update=dat[[1]]$lastupdated)
  }, error=function(e) { failures[[code]] <<- data.frame(code=code,error=conditionMessage(e)) })
}
write_csv(if(length(failures)) do.call(rbind,failures) else data.frame(code=character(),error=character()), 'outputs/tables/collection_failures.csv')
if(!length(rows)) stop('No data collected')
write_csv(do.call(rbind,definitions), 'metadata/source_definitions.csv')
panel <- do.call(rbind, rows); rownames(panel)<-NULL
panel <- merge(panel, countries, by='iso3')
stopifnot(!anyDuplicated(panel[c('iso3','year','code')]))
panel$primary_case <- panel$iso3 %in% cases$iso3
write_csv(panel,'data/clean/international_long.csv')
write_csv(panel[panel$primary_case,], 'data/clean/primary_cases_long.csv')
wide <- reshape(panel[c('iso3','year','code','value')], idvar=c('iso3','year'),timevar='code',direction='wide')
names(wide) <- sub('^value[.]','',names(wide))
write_csv(wide,'data/clean/country_year_panel.csv')
# Full denominator includes every reference economy in metadata, even missing rows.
coverage <- do.call(rbind, lapply(split(panel, interaction(panel$code,panel$year,drop=TRUE)),function(d)
  data.frame(code=d$code[1],year=d$year[1],n_observed=sum(is.finite(d$value)),
             n_reference=nrow(countries),missing_share=1-sum(is.finite(d$value))/nrow(countries))))
write_csv(coverage,'outputs/tables/coverage_by_year.csv')
case_grid <- expand.grid(iso3=cases$iso3, year=START:END, code=catalog$code, stringsAsFactors=FALSE)
case_grid <- merge(case_grid,panel[c('iso3','year','code','value')],all.x=TRUE)
write_csv(aggregate(is.na(value)~iso3+code,case_grid,mean), 'outputs/tables/case_missingness.csv')
transform_value <- function(x, method) { if(method=='log') { x[x<=0]<-NA; log(x) } else x }
scored <- list(); references <- list()
for(code in unique(panel$code)) {
  d <- panel[panel$code==code,]; spec <- catalog[catalog$code==code,]
  d$transformed <- transform_value(d$value,spec$transform)
  for(y in sort(unique(d$year))) {
    s <- d[d$year==y,]; raw <- s$value[is.finite(s$value)]; t <- s$transformed[is.finite(s$transformed)]
    valid <- length(t)>=MIN_REFERENCE && is.finite(sd(t)) && sd(t)>0
    s$z <- if(valid && spec$direction!=0) spec$direction*(s$transformed-mean(t))/sd(t) else NA_real_
    s$percentile <- if(valid && spec$direction!=0) (rank(spec$direction*s$transformed,na.last='keep',ties.method='average')-0.5)/length(t)*100 else NA_real_
    references[[length(references)+1]] <- data.frame(code=code,year=y,n_raw=length(raw),n_transformed=length(t),
      raw_mean=if(length(raw))mean(raw) else NA,raw_sd=sd(raw),transformed_mean=if(length(t))mean(t) else NA,
      transformed_sd=sd(t),eligible=valid)
    scored[[length(scored)+1]] <- s
  }
}
scored <- do.call(rbind,scored)
write_csv(do.call(rbind,references),'outputs/tables/global_reference.csv')
write_csv(scored,'data/clean/standardized_indicators.csv')
# Only approved pilot baskets. Two economic and four living indicators.
scores <- list(); sensitivity <- list()
for(category in c('economic','living')) {
  codes <- catalog$code[catalog$category==category & catalog$composite]
  d <- scored[scored$code %in% codes,]
  for(s in split(d, interaction(d$iso3,d$year,drop=TRUE))) {
    n <- sum(is.finite(s$z)); minimum <- max(2,ceiling(.75*length(codes)))
    score <- if(n>=minimum) mean(s$z,na.rm=TRUE) else NA_real_
    scores[[length(scores)+1]] <- data.frame(iso3=s$iso3[1],year=s$year[1],category=category,
      n_available=n,n_planned=length(codes),minimum=minimum,score=score,
      basket=paste(sort(s$code[is.finite(s$z)]),collapse=';'))
    if(n==length(codes)) for(drop in codes) sensitivity[[length(sensitivity)+1]] <- data.frame(
      iso3=s$iso3[1],year=s$year[1],category=category,dropped=drop,
      full_score=score,leave_one_out=mean(s$z[s$code!=drop]))
  }
}
scores <- do.call(rbind,scores)
write_csv(scores,'data/clean/category_scores.csv')
if(length(sensitivity)) write_csv(do.call(rbind,sensitivity),'outputs/tables/leave_one_out.csv')
write_csv(expand.grid(category=c('happiness','freedom','social'),status='withheld: source or comparability gate unresolved'),
          'outputs/tables/withheld_categories.csv')
source('scripts/02_analysis.R')
writeLines(capture.output(sessionInfo()),'outputs/session_info.txt')
message('Pipeline complete. Read outputs/research_status.md.')



# Refresh the labeled outputs after generating analysis data.
if(!isTRUE(getOption('soda.defer_reader_outputs',FALSE))) source('scripts/05_reader_outputs.R')


