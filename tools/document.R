library(tidyverse)

dir.create(file.path("..", "R"))

# Add UDS-package.R file ----
cat("#' @keywords internal",
  "\"_PACKAGE\"\n",
  "## usethis namespace: start",
  "#' @importFrom rmarkdown pdf_document knitr_options_pdf",
  "## usethis namespace: end",
  "NULL",
  file = file.path('..', 'R', 'UDS-package.R'), sep = '\n')

# function for escaping braces ----
escape <- function(x){
  y <- gsub("{", "\\{", x, fixed = TRUE)
  gsub('\r', ' ', gsub('\n', ' ', gsub("}", "\\}", y, fixed = TRUE)))
}

# get csv data info ----
cat('', file = file.path("..", "R", "data.R"))

rda_files <- list.files("../data", pattern = "\\.rda$", full.names = TRUE, 
  recursive = TRUE)
# Document csv sourced dataset(s) ----
for(ff in rda_files){
  load(ff)
  tt <- gsub(' ', '_', gsub("\\.rda$", "", basename(ff)))
  message('Documenting ', tt)
  assign("dd", get(tt))
  cat(paste0("#' ", tt),
    "#' @description UDS dataset.",
    "#' @details",
    "#' \\itemize{",
    paste("#'   \\item", colnames(dd)),
    "#' }",
    "#' @docType data",
    "#' @keywords datasets",
    paste("#' @name", tt),
    paste0("#' @usage data(", tt, ")"),
    paste("#' @format A data frame with", nrow(dd), "rows and", ncol(dd), "variables."),
    "#' @examples",
    "#' \\dontrun{",
    "#' browseVignettes('UDS')",
    "#' }",
    "NULL\n", sep = "\n",
    file = file.path("..", "R", "data.R"), append = TRUE)          
}

# Add static documents ----
doc_files <- list.files(file.path('..', 'data-raw'), 
  pattern = "\\.pdf$", full.names = TRUE, recursive = TRUE)
for (file_name in doc_files) {
  doc_name <- gsub(' ', '_', gsub("\\.pdf$", "", basename(file_name)))
  file.copy(file_name, file.path('..', 'vignettes', 
    paste0(doc_name,'_original.pdf')))
  cat("\\documentclass{article}",
    "\\usepackage{pdfpages}",
    paste0("%\\VignetteIndexEntry{", doc_name, "}"),
    "\\begin{document}",
    paste0("\\includepdf[pages=-, fitpaper=true]{", paste0(doc_name,'_original.pdf'), "}"),
    "\\end{document}", 
    file = file.path('..', 'vignettes', paste0(doc_name, '.Rnw')),
    sep = '\n')
}

