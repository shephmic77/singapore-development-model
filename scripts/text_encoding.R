# Windows startup may inherit an unsupported C.UTF-8 locale. Do not silently
# substitute <U+....> text for provider names when exporting CSV files.
if(.Platform$OS.type=='windows' && !isTRUE(l10n_info()[['UTF-8']])) {
 result<-suppressWarnings(Sys.setlocale('LC_CTYPE','English_United States.utf8'))
 if(!nzchar(result) || !isTRUE(l10n_info()[['UTF-8']]))
   stop('A UTF-8 text locale is required to preserve provider names. Check Windows R locale settings.')
}
