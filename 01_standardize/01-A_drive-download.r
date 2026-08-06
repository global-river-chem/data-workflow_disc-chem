## ----------------------------------------------- ##
# Download Necessary Standardization Inputs
## ----------------------------------------------- ##
## Purpose:
# The standardization workflow depends on (1) the data inventory, and (2) raw files to standardize
# All relevant inputs are stored in the Drive so this script downloads those algorithmically

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, googledrive, readxl)

# Get set up
source(file = file.path("-setup.r"))

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Download the Data Inventory ----
## ---------------------------------- ##

# Identify file in Drive
(inv_drive <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/1/folders/0AIPkWhVuXjqFUk9PVA")) %>% 
  dplyr::filter(name == "data-inventory"))

# Download it locally
googledrive::drive_download(file = inv_drive$id, overwrite = TRUE, 
  path = file.path("data", paste0(inv_drive$name, "_raw.xlsx")))

# Read in the inventory
invent_v01 <- readxl::read_excel(path = file.path("data", "data-inventory_raw.xlsx"), sheet = "rivers")

# Check structure
dplyr::glimpse(invent_v01)

## ---------------------------------- ##
# Download Raw Data ----
## ---------------------------------- ##

# Compare data in reference table versus already-downloaded raw data
supportR::diff_check(old = unique(invent_v01$raw_filename),
  new = dir(file.path("data", "00_raw")))

# Pare down inventory to only un-downloaded raw files
invent_v02 <- invent_v01 %>% 
  dplyr::filter(!raw_filename %in% dir(file.path("data", "00_raw"))) %>% 
  dplyr::filter(!is.na(raw_filename))

# Re-check structure
dplyr::glimpse(invent_v02)

# Iterate across folders of un-downloaded files
for(focal_folder in unique(invent_v02$data_drive.folder)){
  # focal_folder <- "https://drive.google.com/drive/u/0/folders/1uN-NeF_KtVwvVtR2i3V2RdRjng-vRbLN"
  
  # List files in that folder
  focal_conts <- googledrive::drive_ls(path = googledrive::as_id(focal_folder))

  # Filter inventory to only this Drive folder's raw files
  focal_invent <- invent_v02 %>% 
    dplyr::filter(data_drive.link == focal_folder)

  # Filter to only data files identified in inventory
  focal_raw <- focal_conts %>% 
    dplyr::filter(name %in% focal_invent$raw_filename)

  # Download each of these files!
  purrr::walk2(.x = focal_raw$id, .y = focal_raw$name,
    .f = ~ googledrive::drive_download(file = .x, overwrite = TRUE,
      path = file.path("data", "00_raw", .y)))
  
} # Close folder loop

# Confirm that all raw files in inventory have been downloaded
supportR::diff_check(old = unique(invent_v01$raw_filename),
  new = dir(file.path("data", "00_raw")))

# End ----
