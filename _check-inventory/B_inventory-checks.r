## ----------------------------------------------- ##
# Check Inventory
## ----------------------------------------------- ##
## Purpose:
# Make sure the various sheets of the data inventory are complete & usable by other workflow scripts

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, readxl)

# Get set up
source(file = file.path("-setup.r"))

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Load All Sheets of Inventory ----
## ---------------------------------- ##

# Check what sheets are in the inventory
(readxl::excel_sheets(file.path("data", "data-inventory_raw.xlsx")))

# Load each of the sheets separately
riv_v01 <- readxl::read_excel(path = file.path("data", "data-inventory_raw.xlsx"), sheet = "rivers")
var_v01 <- readxl::read_excel(path = file.path("data", "data-inventory_raw.xlsx"), sheet = "variables")
chem_v01 <- readxl::read_excel(path = file.path("data", "data-inventory_raw.xlsx"), sheet = "chemistry")
dict_v01 <- readxl::read_excel(path = file.path("data", "data-inventory_raw.xlsx"), sheet = "dictionary")

## ---------------------------------- ##
# "Rivers" Sheet Checks ----
## ---------------------------------- ##

# Check the relevant sheet's structure
dplyr::glimpse(riv_v01)

# Check for completeness of key columns for standardization workflow
riv_v02 <- riv_v01 %>% 
  # Pare down to critical columns
  dplyr::select(raw_filename, network_site, country, waterbody, point_id,
    dplyr::ends_with("_col", ignore.case = FALSE)) %>% 
  # Ditch rows without a clear raw file name
  dplyr::filter(!is.na(raw_filename))

# Check structure
dplyr::glimpse(riv_v02)

# Spit out a diagnostic for any rivers that lack _any_ piece of that
riv_v02 %>% 
  dplyr::mutate(na_ct = rowSums(x = is.na(.))) %>% 
  dplyr::filter(na_ct > 0) %>% 
  dplyr::arrange(na_ct) %>% 
  dplyr::select(-na_ct) %>% 
  write.csv(x = ., row.names = FALSE, na = "",
    file = file.path("data", "tests", paste0("B_inventory_rivers_missing-key-std-info_", Sys.Date(), ".csv")))

# Identify rivers that won't have a unique standard filename
riv_v02 %>% 
  dplyr::filter(!is.na(network_site) & !is.na(country) & !is.na(waterbody) & !is.na(point_id)) %>% 
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
    .fns = tolower)) %>% 
  dplyr::group_by(network_site, country, waterbody, point_id) %>% 
  dplyr::summarize(duplicate_ct = dplyr::n(),
    .groups = "drop") %>% 
  dplyr::filter(duplicate_ct > 1) %>% 
  dplyr::mutate(standard_filename = paste0(paste(network_site, country, waterbody, point_id, sep = "_"), ".csv"),
    .before = dplyr::everything()) %>% 
  write.csv(x = ., row.names = FALSE, na = "",
    file = file.path("data", "tests", paste0("B_inventory_rivers_will-have-duplicate-std-name_", Sys.Date(), ".csv")))

## ---------------------------------- ##
# "Variables" Sheet Checks ----
## ---------------------------------- ##

# Check the relevant sheet's structure
dplyr::glimpse(var_v01)

# Identify variables without standard names
var_v01 %>% 
  dplyr::filter(!is.na(variable) & is.na(variable_standard)) %>% 
  dplyr::select(standard_filename:variable_standard) %>% 
  write.csv(x = ., row.names = FALSE, na = "",
    file = file.path("data", "tests", paste0("B_inventory_variables_missing-std-var-name_", Sys.Date(), ".csv")))

# Identify variables without units
var_v01 %>% 
  dplyr::select(standard_filename:unit) %>%  
  dplyr::filter(!is.na(variable) & is.na(unit)) %>% 
  write.csv(x = ., row.names = FALSE, na = "",
    file = file.path("data", "tests", paste0("B_inventory_variables_missing-units_", Sys.Date(), ".csv")))

## ---------------------------------- ##
# "Chemistry" Sheet Checks ----
## ---------------------------------- ##

# Check the relevant sheet's structure
dplyr::glimpse(chem_v01)

# Checks TBD!

## ---------------------------------- ##
# "Dictionary" Sheet Checks ----
## ---------------------------------- ##

# Check the relevant sheet's structure
dplyr::glimpse(dict_v01)

# Make a vector of all column names of other sheets
(all_names <- c(names(riv_v01), names(var_v01), names(chem_v01)))

# Re-generate a dataframe that contains all current column names in each sheet
dict_v02 <- data.frame(
    "sheet" = c(rep("rivers", times = length(names(riv_v01))),
      rep("chemistry", times = length(names(var_v01))),
      rep("variables", times = length(names(chem_v01)))),
    "column_name" = c(names(riv_v01), names(var_v01), names(chem_v01))) %>% 
  # Bind on part of the dictionary
  dplyr::bind_rows(dict_v01 %>% 
    dplyr::filter(!column_name %in% all_names) %>% 
    dplyr::select(sheet, column_name)) %>% 
  dplyr::mutate(status = dplyr::case_when(
    !column_name %in% all_names ~ "column not in (any) sheet",
    column_name %in% dict_v01$column_name ~ "good!",
    !column_name %in% dict_v01$column_name ~ "missing from data dictionary",
    TRUE ~ NA)) %>% 
  dplyr::filter(status != "good!")

# Check structure
dplyr::glimpse(dict_v02)

# Export locally
write.csv(x = dict_v02, row.names = FALSE, na = "",
  file = file.path("data", "tests", paste0("B_inventory_dictionary-updates_", Sys.Date(), ".csv")))

# End ----
