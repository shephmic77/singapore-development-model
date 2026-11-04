source('scripts/text_encoding.R')
options(repos=c(CRAN='https://cloud.r-project.org'))
dir.create('.R-library', showWarnings=FALSE)
.libPaths(c(normalizePath('.R-library'), .libPaths()))
needed <- c('jsonlite', 'sandwich', 'lmtest', 'readxl', 'haven')
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly=TRUE)]
if(length(missing)) install.packages(missing, lib='.R-library')
stopifnot(all(vapply(needed, requireNamespace, logical(1), quietly=TRUE)))
writeLines(capture.output(sessionInfo()), 'outputs/session_info.txt')



