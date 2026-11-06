# Historical and modern policy comparisons. Run from the SODA 308 project root.
source("scripts/text_encoding.R")
.libPaths(c(normalizePath(".R-library"), .libPaths()))
cases <- read.csv("metadata/primary_cases.csv")
countries <- read.csv("metadata/countries.csv")$iso3
wdi <- read.csv("data/clean/country_year_panel.csv", check.names=FALSE)
own <- read.csv("data/clean/state_ownership_control.csv")
imf <- read.csv("data/clean/imf_public_investment.csv")
panel <- read.csv("data/clean/ownership_outcome_analysis_panel.csv")

export_url <- "https://api.worldbank.org/v2/en/indicator/NE.EXP.GNFS.ZS?downloadformat=csv"
cache <- "data/raw/historical_exports_wdi.zip"
if (!file.exists(cache)) {
  pending <- paste0(cache, ".part")
  download.file(export_url,pending,mode="wb",quiet=TRUE)
  stopifnot(any(grepl("^API_NE[.]EXP", unzip(pending,list=TRUE)$Name)),
            file.rename(pending,cache))
}
entry <- grep("^API_NE[.]EXP",unzip(cache,list=TRUE)$Name,value=TRUE)
stopifnot(length(entry)==1)
con <- unz(cache,entry)
exports <- read.csv(con,skip=4,check.names=FALSE)
exports <- exports[exports[["Country Code"]] %in% countries,]
export_series <- do.call(rbind,lapply(1960:2025,function(y)
  data.frame(iso3=exports[["Country Code"]],year=y,value=exports[[as.character(y)]])))
stopifnot(all(is.finite(export_series$value) | is.na(export_series$value)))

# Use same-year current-dollar exports and GDP from one UN release.
un_url <- "https://unstats.un.org/unsd/amaapi/api/file/2"
un_cache <- "data/raw/UNSD_AMA_current_USD.xlsx"
if (!file.exists(un_cache)) {
  pending <- paste0(un_cache,".part.xlsx")
  download.file(un_url,pending,mode="wb",quiet=TRUE)
  stopifnot(length(readxl::excel_sheets(pending))==2L, file.rename(pending,un_cache))
}
un <- readxl::read_excel(un_cache,skip=2)
un_years <- intersect(as.character(1970:2025),names(un))
un_exports <- do.call(rbind,lapply(c(PHL=608,ZMB=894),function(id) {
  d <- un[un$CountryID==id,]
  x <- d[d$IndicatorName=="Exports of goods and services",un_years]
  g <- d[d$IndicatorName=="Gross Domestic Product (GDP)",un_years]
  stopifnot(nrow(x)==1L,nrow(g)==1L)
  exports_usd <- as.numeric(x)
  gdp_usd <- as.numeric(g)
  data.frame(iso3=if(id==608) "PHL" else "ZMB",year=as.integer(un_years),
             exports_usd=exports_usd,gdp_usd=gdp_usd,
             un_share=ifelse(is.finite(gdp_usd) & gdp_usd>0,100*exports_usd/gdp_usd,NA_real_))
}))
export_audit <- merge(un_exports,export_series,by=c("iso3","year"),all.x=TRUE)
names(export_audit)[names(export_audit)=="value"] <- "wdi_share"
export_audit$un_minus_wdi <- export_audit$un_share-export_audit$wdi_share
export_audit$added <- with(export_audit,year<=1999 & !is.finite(wdi_share) & is.finite(un_share))
supplements <- export_audit[export_audit$added,]
match_row <- match(paste(supplements$iso3,supplements$year),paste(export_series$iso3,export_series$year))
stopifnot(!anyNA(match_row), all(is.na(export_series$value[match_row])),
          all(supplements$exports_usd>=0), all(supplements$gdp_usd>0))
export_series$value[match_row] <- supplements$un_share

v <- new.env()
load("data/raw/v16_vdem.RData",v)
raw <- v[[ls(v)[1]]]
stopifnot(all(c("country_text_id","year","v2clrspct_osp") %in% names(raw)))
cross <- read.csv("metadata/vdem_country_crosswalk.csv")
cross <- cross[!is.na(cross$iso3) & nzchar(cross$iso3),c("country_text_id","iso3")]
admin <- merge(raw[c("country_text_id","year","v2clrspct_osp")],cross,by="country_text_id")
imf$public_capital_ratio <- ifelse(is.finite(imf$GDP_rppp) & imf$GDP_rppp>0,
                                  100*imf$kgov_rppp/imf$GDP_rppp,NA_real_)
extract <- function(d, column, name) {
  x <- d[d$iso3 %in% countries,c("iso3","year",column)]
  stopifnot(!anyDuplicated(x[c("iso3","year")]))
  names(x)[3] <- "value"
  x$metric <- name
  x
}
series <- rbind(
  extract(wdi,"BX.KLT.DINV.WD.GD.ZS","Net inward FDI (% GDP)"),
  extract(export_series,"value","Exports of goods and services (% GDP)"),
  extract(imf,"public_capital_ratio","Public capital stock / GDP (x 100)"),
  extract(own,"ownership_control_0_4","State ownership (0-4)"),
  extract(imf,"government_investment_pct_gdp","Government fixed investment (% GDP)"),
  extract(wdi,"NE.TRD.GNFS.ZS","Trade (% GDP)"),
  extract(wdi,"GOV_WGI_GE.EST","WGI government effectiveness"),
  extract(admin,"v2clrspct_osp","V-Dem impartial administration (0-4)")
)
series <- series[!(series$iso3=="SGP" & series$year<1965),]
historical <- subset(series, year>=1960 & year<=1999)
peer <- subset(historical, !iso3 %in% cases$iso3 & is.finite(value))
means <- aggregate(value~metric+year,peer,mean)
names(means)[3] <- "outside_mean"
counts <- aggregate(value~metric+year,peer,length)
names(counts)[3] <- "outside_n"
reference <- merge(means,counts,by=c("metric","year"))
focus <- expand.grid(iso3=cases$iso3,year=1960:1999,metric=unique(series$metric))
focus <- merge(focus,historical,by=c("iso3","year","metric"),all.x=TRUE)
focus <- merge(focus,reference,by=c("metric","year"),all.x=TRUE)
focus$outside_n[is.na(focus$outside_n)] <- 0L
focus$gap <- focus$value-focus$outside_mean
focus$benchmark <- ifelse(focus$outside_n>=100,"100+ outside economies","Limited coverage")
focus$evidence <- ifelse(is.finite(focus$value),"Source value","Missing")
is_un <- focus$metric=="Exports of goods and services (% GDP)" &
  paste(focus$iso3,focus$year) %in% paste(supplements$iso3,supplements$year)
focus$evidence[is_un] <- "UNSD AMA supplement"
focus$evidence[focus$metric=="Exports of goods and services (% GDP)" &
               is.finite(focus$value) & !is_un] <- "World Bank WDI"
stopifnot(sum(is_un)==nrow(supplements),
          all(focus$value[is_un]==supplements$un_share[match(
            paste(focus$iso3[is_un],focus$year[is_un]),paste(supplements$iso3,supplements$year))]))
stopifnot(nrow(focus)==11*40*length(unique(series$metric)),
          all(!is.finite(focus$value[focus$iso3=="SGP" & focus$year<1965])))
coverage <- aggregate(is.finite(value)~iso3+metric,focus,sum)
names(coverage)[3] <- "years_with_values"
coverage$first_year <- vapply(seq_len(nrow(coverage)),function(i) {
  y <- focus$year[focus$iso3==coverage$iso3[i] & focus$metric==coverage$metric[i] & is.finite(focus$value)]
  if(length(y)) min(y) else NA_integer_
},integer(1))

# Predictor year is already explicit in the existing outcome panel.
extras <- Reduce(function(a,b) merge(a,b,by=c("iso3","predictor_year"),all=TRUE),
  lapply(list(fdi=wdi[c("iso3","year","BX.KLT.DINV.WD.GD.ZS")],
              exports=export_series[c("iso3","year","value")],
              public_stock=imf[c("iso3","year","public_capital_ratio")]),
    function(x) { names(x)[2] <- "predictor_year"; x }))
names(extras)[match(c("BX.KLT.DINV.WD.GD.ZS","value","public_capital_ratio"),names(extras))] <-
  c("fdi","exports","public_stock")
panel <- merge(panel,extras,by=c("iso3","predictor_year"),all.x=TRUE)
base <- c("state_control","public_investment","trade","effectiveness")
specs <- list(Baseline=base, FDI=c(base,"fdi"),
              Exports=c(setdiff(base,"trade"),"exports"),
              Public_stock=c(setdiff(base,"public_investment"),"public_stock"))
model_rows <- list()
for (outcome in c("economic_growth","living_available_basket","gender_inequality_index")) {
  d <- panel[complete.cases(panel[c(outcome,base,"fdi","exports","public_stock")]),]
  nc <- length(unique(d$iso3))
  stopifnot(all(d$predictor_year==d$year-1))
  if (nrow(d)<100 || nc<30) next
  for (name in names(specs)) {
    terms <- specs[[name]]
    fit <- lm(reformulate(c(terms,"factor(iso3)","factor(year)"),outcome),data=d)
    vc <- sandwich::vcovCL(fit,cluster=d$iso3,type="HC1")
    b <- coef(fit)[terms]
    se <- sqrt(diag(vc))[terms]
    stopifnot(all(is.finite(b)),all(is.finite(se)))
    margin <- qt(.975,nc-1)*se
    model_rows[[length(model_rows)+1L]] <- data.frame(
      Outcome=outcome, Specification=name, Predictor=terms, Estimate=b,
      Lower=b-margin,Upper=b+margin,Rows=nrow(d),Economies=nc,
      First=min(d$year),Last=max(d$year),row.names=NULL)
  }
}
models <- do.call(rbind,model_rows)
stopifnot(nrow(models)==51)
saveRDS(list(historical_focus=focus, outside_reference=reference, coverage=coverage,
             model_coefficients=models, export_audit=export_audit, un_url=un_url,
             un_archive_md5=unname(tools::md5sum(un_cache)), export_url=export_url,
             export_archive_md5=unname(tools::md5sum(cache))),
        "outputs/historical_policy_analysis.rds")
table_html <- function(x) {
  x[] <- lapply(x,function(z) ifelse(is.na(z),"Missing",if(is.numeric(z)) format(round(z,3),trim=TRUE) else z))
  c("<table><thead><tr>",paste0("<th>",gsub("_"," ",names(x)),"</th>"),"</tr></thead><tbody>",
    apply(x,1,function(r) paste0("<tr><td>",paste(r,collapse="</td><td>"),"</td></tr>")),
    "</tbody></table>")
}
snapshot <- subset(focus,year==1980 & metric %in% unique(series$metric)[c(1:3,8)])
snapshot$iso3 <- cases$name[match(snapshot$iso3,cases$iso3)]
writeLines(c('<!doctype html><html lang="en"><meta charset="utf-8"><title>Historical policy measures and models</title>',
  '<style>body{font:16px/1.55 system-ui;color:#17313d;max-width:1160px;margin:32px auto;padding:0 20px}table{width:100%;border-collapse:collapse;margin-bottom:30px}td,th{text-align:left;padding:8px;border-bottom:1px solid #dce6e7}th{background:#eef6f5}</style>',
  "<h1>Historical policy measures and models</h1>",
  '<p>Exports are goods and services as a share of GDP. FDI is net inward investment as a share of GDP. Public capital is the IMF estimate of accumulated government assets divided by real GDP in the same constant 2017 PPP units, multiplied by 100. A stock can exceed one year of GDP.</p>',
  '<p>V-Dem impartial administration provides a separate historical measure of how officials apply rules. Its 0–4 scale is distinct from World Bank government effectiveness. Source values include provider estimates. Project predictions appear only in the <a href="HISTORICAL_GAP_PILOT.html">separate gap pilot</a>.</p>',
  '<p>Each comparison uses the equal-weight mean of reporting economies outside the 11 cases. Counts below 100 are flagged. Historical reporting units need boundary and continuity review. Singapore before 1965 is outside the independent-country analysis.</p>',
  "<h2>1980 comparison for the added measures</h2>",
  table_html(snapshot[c("iso3","metric","value","outside_mean","outside_n","gap","benchmark","evidence")]),
  "<h2>Coverage across the 11 cases, 1960–1999</h2>",
  table_html(coverage),
  "<h2>Annual comparisons for each focus economy</h2>",
  unlist(lapply(seq_len(nrow(cases)),function(i) {
    d <- focus[focus$iso3==cases$iso3[i],c("year","metric","value","outside_mean","outside_n","gap","evidence")]
    d <- d[order(d$metric,d$year),]
    c(paste0("<details><summary>",cases$name[i],"</summary>"),table_html(d),"</details>")
  })),
  "<h2>UN export data check</h2>",
  sprintf("<p>UNSD supplied %d historical values for gaps in World Bank exports. I divide exports of goods and services by GDP in the same UN current-dollar table. World Bank values take priority wherever available. The 1960s remain outside this UN workbook's coverage.</p>",nrow(supplements)),
  "<p>Both sources measure goods and services exports as a share of GDP. Differences in their overlapping years can reflect revisions or different national accounts vintages. Read the source label before interpreting changes across a source switch. The supplements affect only the two focus economies and do not change the outside averages or the modern model samples.</p>",
  '<p><a href="https://unstats.un.org/unsd/snaama/downloads">UNSD National Accounts Main Aggregates, current US dollars workbook</a></p>',
  table_html(aggregate(added~iso3,export_audit,sum)),
  "<details><summary>Inspect the two sources and overlap by year</summary>",
  table_html(export_audit),"</details>",
  "<h2>Remaining source checks</h2>",
  '<p>Earlier export gaps still need annual data with matching exports and GDP definitions. The UN historical survey reports some early multi-year export ratios, which need to stay distinct from annual data. Barro-Lee provides a five-year education series to check against sparse annual education data. <a href="https://unstats.un.org/unsd/snaama/downloads">UN national accounts</a> · <a href="https://www.un.org/en/development/desa/policy/wess/wess_archive/1969_1970wes.pdf">UN historical survey</a> · <a href="https://barrolee.github.io/BarroLeeDataSet/">Barro-Lee education data</a></p>',
  "<h2>Matched-sample models</h2>",
  "<p>Within each outcome, all specifications use the same complete rows, previous-year predictors, economy and year effects, and economy-clustered 95% confidence intervals. The baseline uses four predictors. The FDI check adds a fifth to see what it contributes alongside trade. Exports replace trade in one check and capital stock replaces investment in another. These estimates describe associations.</p>",
  table_html(models),
  '<p><a href="https://data.worldbank.org/indicator/NE.EXP.GNFS.ZS">World Bank exports</a> · <a href="https://data.imf.org/Datasets/ICSD">IMF capital data</a> · <a href="https://v-dem.net/data/the-v-dem-dataset/">V-Dem data</a> · <a href="PAPER_EVIDENCE_GUIDE.html">Working guide</a></p></html>'
), "outputs/HISTORICAL_POLICY_ANALYSIS.html",useBytes=TRUE)
print(unique(models[c("Outcome","Rows","Economies","First","Last")]))
print(subset(models, Predictor %in% c("fdi","exports","public_stock")))
print(aggregate(years_with_values~metric,coverage,sum))
