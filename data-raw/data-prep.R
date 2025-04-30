library(tidyverse); library(devtools);

# Create R package data directory ----
dir.create(file.path('..', 'data'))
file.remove(file.path('..', 'data', list.files('../data')))

# Store release number and date ----
data_release_date <- as.Date("2025-01-29")
data_release_major_version <- "1"
data_release_version <- "1.0"
NA_STRINGS <- c('-9999', '-8888', '-777777', 'NULL', 'NaT')
usethis::use_data(data_release_date, overwrite = TRUE)
usethis::use_data(data_release_version, overwrite = TRUE)

# Read and store csv files ----
csv_files <- list.files('./Data_Integration_20250129/', 
  pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)

## Skip the _Build folders of dervied data
csv_files <- grep("_Build", csv_files, value = TRUE, invert = TRUE, fixed = TRUE)

for (file_name in csv_files) {
  df_name <- basename(file_name) %>%
    gsub(pattern = "\\.csv$", replacement = "") %>%
    gsub(pattern = ' ', replacement = '_') %>%
    gsub(pattern = '-', replacement = '_')
  df <- readr::read_csv(file_name)
  assign(df_name, df)
  # using defaults from usethis::use_data
  save(list = df_name, file = file.path("..", "data", paste0(df_name, ".rda")),
    compress = "bzip2", version = 2)
}

# Read and store txt files ----
txt_files <- list.files('./Data_Integration_20250129/', 
  pattern = "\\.txt$", full.names = TRUE, recursive = TRUE)
txt_files <- grep("_Build", txt_files, value = TRUE, invert = TRUE, fixed = TRUE)

for (file_name in txt_files) {
  df_name <- basename(file_name) %>%
    gsub(pattern = "\\.txt$", replacement = "") %>%
    gsub(pattern = ' ', replacement = '_') %>%
    gsub(pattern = '-', replacement = '_')
  df <- readr::read_csv(file_name)
  assign(df_name, df)
  # using defaults from usethis::use_data
  save(list = df_name, file = file.path("..", "data", paste0(df_name, ".rda")),
    compress = "bzip2", version = 2)
}

# Read and store dictionary files ----
xlsx_files <- list.files('./Data_Integration_20250129/', 
  pattern = "\\.xlsx$", full.names = TRUE, recursive = TRUE)

dict_files <- c(
  "./Data_Integration_20250129//Data_Integration Data Files/NACC_MUSE_Neuropath_Build/NACC_T1_MUSE_Data_Dictionary_2024.12.xlsx",
  "./Data_Integration_20250129//Data_Integration Data Files/PHC_NP_Data_Map_NACC_20231020.xlsx",
  "./Data_Integration_20250129//Data_Integration Data Files/PHC_NP_NACC_Data_Dictionary_20231020.xlsx")

for (file_name in dict_files) {
  df_name <- basename(file_name) %>%
    gsub(pattern = "\\.xlsx$", replacement = "") %>%
    gsub(pattern = ' ', replacement = '_') %>%
    gsub(pattern = '-', replacement = '_')
  df <- readxl::read_excel(file_name)
  assign(df_name, df)
  # using defaults from usethis::use_data
  save(list = df_name, file = file.path("..", "data", paste0(df_name, ".rda")),
    compress = "bzip2", version = 2)
}

get_levels <- function(x){
  as.numeric(unlist(lapply(strsplit(unlist(strsplit(subset(
    PHC_NP_NACC_Data_Dictionary_20231020, VariableName==x)$`Coding`, '\r\n',
    fixed = TRUE)), '='), function(y) y[1])))
}

get_labels <- function(x){
  unlist(lapply(strsplit(unlist(strsplit(subset(
    PHC_NP_NACC_Data_Dictionary_20231020, VariableName==x)$`Coding`, '\r\n',
    fixed = TRUE)), '='), function(y) y[2]))
}

for(df_name in c('investigator_ftldlbd_nacc66', 
  'uds_taupet_autopsy_overlap_mixed_prospective',
  'mds05072024')){
  df <- get(df_name)
  for(cc in colnames(df)){
    dic.sub <- subset(PHC_NP_NACC_Data_Dictionary_20231020, VariableName==cc & 
        !grepl("numeric", Coding))
    if(nrow(dic.sub)==1){
        if(length(get_levels(cc)) == length(get_labels(cc)) & !any(is.na(get_levels(cc)))){
          message('Coding ', cc)
          # subset(HD_Data_Dictionary, `Main Variable`==cc)$`Value`
          df[, cc] <- factor(df %>% pull(cc), 
            levels = get_levels(cc),
            labels = get_labels(cc))}
        if(length(get_levels(cc))>0 & any(is.na(get_levels(cc))))
          message(paste(df_name, cc, "levels:", get_levels(cc)))
    }
  }
  assign(df_name, df)
  save(list = df_name, file = file.path("..", "data", paste0(df_name, ".rda")),
    compress = "bzip2", version = 2)
}

# Derived data ----
# knitr::purl('../vignettes/UDS-Derived-Data.Rmd',
#   'UDS-Derived-Data.R')
# 
# source('UDS-Derived-Data.R')
# 
# usethis::use_data(..., overwrite = TRUE)
