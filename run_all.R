# Run the complete R project from its root folder, or source this file in RStudio.
options(soda.defer_reader_outputs=TRUE)
for(script in c('00_setup.R','01_pipeline.R','03_sensitivity.R','06_additional_sources.R','07_expanded_analysis.R','09_peer_benchmarks.R','10_intervention_social_sources.R','11_intervention_social_analysis.R','13_better_measure_sources.R','14_ownership_social_analysis.R')) {
 message('\nRunning ',script);source(file.path('scripts',script))
}
options(soda.defer_reader_outputs=FALSE)
source('scripts/05_reader_outputs.R')
source('tests/validate.R')
source('tests/validate_extended.R')
source('tests/validate_intervention_social.R')
source('tests/validate_better_measures.R')
writeLines(capture.output(sessionInfo()),'outputs/session_info.txt')
message('Finished. Open outputs/BETTER_MEASURES.html for the latest results.')



