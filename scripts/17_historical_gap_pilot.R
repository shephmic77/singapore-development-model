# Historical pilot. Run from the SODA 308 project folder.
cases <- read.csv("metadata/primary_cases.csv")
years <- 1965:1999
wdi <- read.csv("data/clean/country_year_panel.csv", check.names=FALSE)
own <- read.csv("data/clean/state_ownership_control.csv")
imf <- read.csv("data/clean/imf_public_investment.csv")
gii <- read.csv("data/clean/undp_gender_inequality.csv")
freedom <- read.csv("data/clean/freedom_category_scores.csv")
series <- function(data, key, label, eligible=FALSE) {
  stopifnot(!anyDuplicated(data[c("iso3","year")]))
  list(data=data, key=key, label=label, eligible=eligible)
}
metrics <- list(
  series(own,"ownership_control_0_4","State ownership"),
  series(imf,"government_investment_pct_gdp","Public fixed investment (% GDP)",TRUE),
  series(imf,"kgov_rppp","Public capital stock (IMF real PPP units)"),
  series(wdi,"NE.TRD.GNFS.ZS","Trade (% GDP)",TRUE),
  series(wdi,"BX.KLT.DINV.WD.GD.ZS","Inward FDI, net (% GDP)",TRUE),
  series(wdi,"GOV_WGI_GE.EST","Government effectiveness"),
  series(wdi,"NY.GDP.PCAP.KD.ZG","Real GDP per person growth (%)",TRUE),
  series(wdi,"NY.GDP.PCAP.PP.KD","Real PPP GDP per person",TRUE),
  series(wdi,"SP.DYN.LE00.IN","Life expectancy (years)",TRUE),
  series(wdi,"SP.DYN.IMRT.IN","Infant deaths per 1,000 live births",TRUE),
  series(wdi,"SE.SEC.CUAT.UP.ZS","Secondary attainment (%)"),
  series(wdi,"EG.ELC.ACCS.ZS","Electricity access (%)",TRUE),
  series(freedom,"score","Freedom score"),
  series(gii,"gender_inequality_index","Gender inequality index")
)
coverage <- estimates <- list()
for (metric in metrics) {
  for (case in seq_len(nrow(cases))) {
    id <- cases$iso3[case]
    d <- metric$data[metric$data$iso3 == id,]
    y <- d[[metric$key]][match(years,d$year)]
    observed <- is.finite(y)
    n <- length(years)
    accepted <- 0L
    if (metric$eligible && any(observed)) {
      runs <- rle(!observed)
      ends <- cumsum(runs$lengths)
      for (r in which(runs$values & runs$lengths <= 2L)) {
        gap <- runs$lengths[r]
        right <- ends[r]+1L
        left <- right-gap-1L
        if (left<1L || right>n) next
        error <- baseline <- numeric()
        # Hide known blocks of the same length in the same economy and metric.
        for (a in seq_len(n-gap-1L)) {
          b <- a+gap+1L
          window <- a:b
          if (!all(observed[window])) next
          test <- (a+1L):(b-1L)
          fitted <- approx(years[c(a,b)],y[c(a,b)],xout=years[test])$y
          error <- c(error, abs(fitted-y[test]))
          nearest <- ifelse(test-a<=b-test,y[a],y[b])
          baseline <- c(baseline,abs(nearest-y[test]))
        }
        if (length(error)<10L || mean(error)>mean(baseline)) next
        test <- (left+1L):(right-1L)
        fitted <- approx(years[c(left,right)],y[c(left,right)],xout=years[test])$y
        estimates[[length(estimates)+1L]] <- data.frame(
          Economy=cases$name[case], Metric=metric$label, Year=years[test],
          Estimate=round(fitted,3), Earlier=years[left], Later=years[right],
          Validation_points=length(error), Trend_MAE=round(mean(error),3),
          Nearest_MAE=round(mean(baseline),3))
        accepted <- accepted+length(test)
      }
    }
    coverage[[length(coverage)+1L]] <- data.frame(
      Economy=cases$name[case], Metric=metric$label, Source_values=sum(observed),
      Pilot_estimates=accepted, Still_missing=sum(!observed)-accepted)
  }
}
coverage <- do.call(rbind,coverage)
estimates <- if(length(estimates)) do.call(rbind,estimates) else data.frame()
stopifnot(nrow(coverage)==11L*length(metrics), all(coverage$Still_missing>=0),
          sum(coverage$Pilot_estimates)==nrow(estimates))
html_table <- function(x) {
  c("<table><thead><tr>",paste0("<th>",gsub("_"," ",names(x)),"</th>"),
    "</tr></thead><tbody>",
    apply(x,1,function(row)paste0("<tr><td>",paste(row,collapse="</td><td>"),"</td></tr>")),
    "</tbody></table>")
}
writeLines(c(
  '<!doctype html><html lang="en"><meta charset="utf-8"><title>Historical gaps in the 11 focus economies</title>',
  '<style>body{font:16px/1.55 system-ui;color:#172b36;max-width:1120px;margin:32px auto;padding:0 20px}table{border-collapse:collapse;width:100%;margin-bottom:30px}th,td{text-align:left;border-bottom:1px solid #dce6e7;padding:8px}th{background:#eef6f5}</style>',
  "<h1>Historical gaps in the 11 focus economies</h1>",
  "<p>I checked 1965 through 1999 for each economy. Source values include estimates already published by providers. My own estimates are listed separately below.</p>",
  "<p>I try a straight line only for gaps of one or two years with source values on both sides. I hide known values in blocks of the same length in the same economy and measure the typical error. I require at least ten validation points and error no greater than copying the nearest value. Validation windows can overlap, so these errors are a screening check.</p>",
  "<p>I leave leading and trailing gaps open, including early government effectiveness. Survey and expert index gaps stay open in this pilot. Happiness uses published periods and is outside this annual pilot. The estimates stay separate from original data, scores, models, and benchmarks.</p>",
  sprintf("<h2>Provisional estimates (%d)</h2>",nrow(estimates)),
  if(nrow(estimates)) html_table(estimates) else "<p>No gaps passed these rules.</p>",
  "<h2>Coverage by economy and statistic</h2>",html_table(coverage),
  '<p><a href="PAPER_EVIDENCE_GUIDE.html">Back to the working guide</a></p></html>'
), "outputs/HISTORICAL_GAP_PILOT.html")
cat("Economies:",nrow(cases),"Coverage rows:",nrow(coverage),"Estimates:",nrow(estimates),"\n")
if(nrow(estimates)) print(estimates)
