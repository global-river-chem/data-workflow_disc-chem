## ----------------------------------------------- ##
# Standardize Raw Data
## ----------------------------------------------- ##
## Purpose:
# Accept raw river data and standardize it into the format required by later scripts
# Note this is done on a per-river basis so will create as many standard files as there were raw files
## This is _many_ files so expect the per-river operation to be quick but the total operation to be time-consuming

# This script has one section per data structure in the raw data
# That way we can loop across data with the same structure and transform them all into the globally-standardized format

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, readxl)

# Clear environment + collect garbage
rm(list = ls()); gc()

# Load custom functions
source(file = file.path("tools", "fxn_river-chem-format.r"))

## ---------------------------------- ##
# Check Data Inventory ----
## ---------------------------------- ##

# Read in the inventory
invent_v01 <- readxl::read_excel(path = file.path("data", "data-inventory.xlsx"), sheet = "rivers")

# Check structure
dplyr::glimpse(invent_v01)

# Prep the data inventory
## I.e., remove empty rows, missing standard file name elements, etc.
invent_v02 <- invent_v01 %>% 
  dplyr::filter(!is.na(raw_filename)) %>% 
  dplyr::filter(!is.na(network_site) & !is.na(country) & !is.na(waterbody) & !is.na(point_id))

# Check structure
dplyr::glimpse(invent_v02)

## ---------------------------------- ##
# Prepare Standardized File Names ----
## ---------------------------------- ##

# Assemble standardize filenames from relevant columns of inventory
invent_v03 <- invent_v02 %>% 
  dplyr::mutate(dplyr::across(.cols = dplyr::all_of(c("network_site", "country", "waterbody", "point_id")),
    .f = ~ tolower(gsub(pattern = " |_", replacement = "-", x = .)))) %>% 
  dplyr::mutate(std_filename = paste0(network_site, "_", country, "_", waterbody, "_", point_id, ".csv"),
    .before = incl_discharge)

# Check structure
dplyr::glimpse(invent_v03)

# Which (if any) standard file names are not unique?
invent_v03 %>% 
  dplyr::group_by(std_filename) %>% 
  dplyr::summarize(ct = dplyr::n(), .groups = "drop") %>% 
  dplyr::filter(ct > 1)

# Actually throw an error for non-unique standard file names
if(nrow(invent_v03) != length(unique(invent_v03$std_filename))){
  stop("Every standard file name MUST be unique")
}

## ---------------------------------- ##
# Final Pre-Flight Checks ----
## ---------------------------------- ##

# Identify local raw data
raw_v01 <- dir(path = file.path("data", "00_raw"))

# Pare that down to only raw files with standard names
(raw_v02 <- intersect(x = raw_v01, y = unique(invent_v03$raw_filename)))

## ---------------------------------- ##
# Standardize 'Master 2026' Data ----
## ---------------------------------- ##

# Pare the inventory down to just data from this source/with this structure
focal_invent <- invent_v03 %>% 
  dplyr::filter(data_repository == "From 2026 \"master\" harmonized files")

# Pare raw files down to just those as well
(focal_raw <- intersect(x = raw_v02, y = unique(focal_invent$raw_filename)))

# Loop across raw data files, performing standardization as we go
for(focal_data in focal_raw){
  # focal_data <- "master2026_chemistry-river-10_Xibeco.csv"

  # Read in the data
  river_raw <- read.csv(file = file.path("data", "00_raw", focal_data))

  # Grab relevant row of inventory
  river_invent <- dplyr::filter(focal_invent, raw_filename == focal_data)

  # Progress message
  message("Standardizing ", river_invent$std_filename)

  # Wrangle to desired information in desired format
  river_std <- river_chem_format(river = river_raw, date_col = "date",
    var_col = "variable", unit_col = "units", value_col = "value")

  # Export
  write.csv(x = river_std, row.names = FALSE, na = '',
    file = file.path("data", "01_standard", river_invent$std_filename))
}

# Tidy up environment
rm(list = c("focal_invent", "focal_raw", "focal_data", 
  "river_raw", "river_invent", "river_std")); gc()

# End ----
