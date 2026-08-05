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

# End ----
