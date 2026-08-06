## ----------------------------------------------- ##
# Standardize Raw Data _Structure_
## ----------------------------------------------- ##
## Purpose:
# Accept raw river data and standardize it into the format required by later scripts
# Note this is done on a per-river basis so will create as many standard files as there were raw files
## This is _many_ files so expect the per-river operation to be quick but the total operation to be time-consuming

# This script has one section per data structure in the raw data
# That way we can loop across data with the same structure and transform them all into the globally-standardized format

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, readxl)

# Get set up
source(file = file.path("-setup.r"))

# Clear environment + collect garbage
rm(list = ls()); gc()

# Load custom functions
source(file = file.path("tools", "fxn_river-chem-format.r"))

## ---------------------------------- ##
# Check Data Inventory ----
## ---------------------------------- ##

# Read in the inventory
invent_v01 <- readxl::read_excel(path = file.path("data", "data-inventory_raw.xlsx"), sheet = "rivers")

# Check structure
dplyr::glimpse(invent_v01)

# Prep the data inventory
## I.e., remove empty rows, missing standard file name elements, pare down to needed columns, etc.
invent_v02 <- invent_v01 %>% 
  dplyr::filter(!is.na(raw_filename)) %>% 
  dplyr::filter(!is.na(network_site) & !is.na(country) & !is.na(waterbody) & !is.na(point_id)) %>% 
  dplyr::select(raw_filename, network_site, country, waterbody, point_id, dplyr::ends_with("_col"))

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
    .after = raw_filename)

# Check structure
dplyr::glimpse(invent_v03)

# Which (if any) standard file names are not unique?
(non.unq <- invent_v03 %>% 
  dplyr::group_by(std_filename) %>% 
  dplyr::summarize(ct = dplyr::n(), .groups = "drop") %>% 
  dplyr::filter(ct > 1))

# Actually throw a warning for non-unique standard file names
if(nrow(invent_v03) != length(unique(invent_v03$std_filename))){
  warning("Every standard file name MUST be unique. ", sum(non.unq$ct), " duplicates found.") }

# Ditch non-unique rivers
invent_v04 <- invent_v03 %>% 
  dplyr::filter(!std_filename %in% non.unq$std_filename)

# Check structure
dplyr::glimpse(invent_v04)

## ---------------------------------- ##
# Final Pre-Flight Checks ----
## ---------------------------------- ##

# Identify local raw data
raw_v01 <- dir(path = file.path("data", "00_raw"))

# Pare that down to only raw files with standard names
(raw_v02 <- intersect(x = raw_v01, y = unique(invent_v04$raw_filename)))

# Further streamline the inventory
invent_v05 <- invent_v04 %>% 
  dplyr::filter(raw_filename %in% raw_v02)

# Check structure
dplyr::glimpse(invent_v05)

## ---------------------------------- ##
# Standardize Structure ----
## ---------------------------------- ##

# Loop across raw data files, performing standardization as we go
for(focal_data in sort(invent_v05$std_filename)){
  # focal_data <- "camrex-amazon_brazil_amazon_02.csv"

  # Progress message
  message("Standardizing '", focal_data, "'")

  # Grab relevant row of inventory
  river_invent <- dplyr::filter(invent_v05, std_filename == focal_data)

  # Error out if that's more than one row (shouldn't be possible but better safe than sorry)
  if(nrow(river_invent) != 1)
    stop("More than one river found matching this standard filename!")

  # Read in the data
  river_raw <- read.csv(file = file.path("data", "00_raw", river_invent$raw_filename))

  # Wrangle to desired information in desired format
  river_std <- river_chem_format(river = river_raw, 
    date_col = river_invent$date_col, var_col = river_invent$var_col, 
    unit_col = river_invent$unit_col, value_col = river_invent$value_col)

  # Export
  write.csv(x = river_std, row.names = FALSE, na = '',
    file = file.path("data", "01-B_std-structure", paste0("01-B_", river_invent$std_filename)))
}

# End ----
