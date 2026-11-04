# Base-R checks for the published repository; no raw data or downloads required.
required <- c('README.md','SOURCE_NOTES.md','run_all.R','SODA308.Rproj',
              'sync_github.ps1','docs/github_sync.md','metadata/output_catalog.csv',
              'outputs/START_HERE.html','outputs/CURRENT_RESULTS.html',
              'outputs/INTERVENTION_SOCIAL.html','outputs/BETTER_MEASURES.html')
stopifnot(all(file.exists(required)))
for (f in c('run_all.R', list.files('scripts', '[.]R$', full.names=TRUE),
            list.files('tests', '[.]R$', full.names=TRUE))) parse(f)
reports <- required[grepl('[.]html$', required)]
for (f in reports) {
  contents <- paste(readLines(f, warn=FALSE, encoding='UTF-8'), collapse='\n')
  links <- regmatches(contents, gregexpr('(href|src)="[^"]+"', contents, perl=TRUE))[[1]]
  links <- sub('^[^"]*"([^"]+)"$', '\\1', links)
  links <- links[!grepl('^(https?:|mailto:|data:|#)', links)]
  paths <- file.path(dirname(f), sub('[?#].*$', '', links))
  missing <- paths[!file.exists(paths)]
  if (length(missing)) stop('Broken report links: ', paste(missing, collapse=', '))
}
catalog <- read.csv('metadata/output_catalog.csv', stringsAsFactors=FALSE)
stopifnot(!anyDuplicated(catalog$file), all(file.exists(catalog$file)))
# Readable exports must have unique headings and the catalogued row counts.
for (i in seq_len(nrow(catalog))) {
  d <- read.csv(catalog$file[i], check.names=FALSE)
  stopifnot(nrow(d)==catalog$rows[i], !anyDuplicated(names(d)))
}
# Check local Markdown links in the new entry-point guides.
guides <- c('README.md','SOURCE_NOTES.md', paste0(c('data','docs','metadata','outputs','scripts','tests'), '/README.md'), 'docs/github_sync.md','coursework/README.md','docs/coursework_and_current_analysis.md')
for (f in guides) {
  contents <- paste(readLines(f, warn=FALSE, encoding='UTF-8'), collapse='\n')
  links <- regmatches(contents, gregexpr('\\]\\([^)]*\\)', contents, perl=TRUE))[[1]]
  links <- substring(links, 3, nchar(links)-1)
  links <- links[!grepl('^(https?:|mailto:|#)', links)]
  if (length(links)) stopifnot(all(file.exists(file.path(dirname(f), sub('#.*$', '', links)))))
}
manifest <- read.csv('coursework/document_manifest.csv', stringsAsFactors=FALSE)
stopifnot(nrow(manifest)==8, !anyDuplicated(manifest$repository_file), all(file.exists(manifest$repository_file)))
stopifnot(all(file.info(manifest$repository_file)$size==manifest$bytes))
cat(sprintf('PASS: R syntax, four report link sets, %d catalogued readable exports, and repository guide links.\n', nrow(catalog)))