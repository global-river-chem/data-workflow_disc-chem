## ----------------------------------------------- ##
# Upload Standardization Outputs
## ----------------------------------------------- ##
## Purpose:
# Uploads standardized data files to Drive
# If file is in Drive already, defaults to not overwriting (to save computing time)
# If re-upload of one/few files is desired, delete them in the Drive rather than changing the 'update_drive' object
## Because changing that object will make _all_ files overwrite which will be _immensely_ time-consuming

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, readxl, googledrive)

# Get set up
source(file = file.path("-setup.r"))

# Clear environment + collect garbage
rm(list = ls()); gc()

# Should files in Drive be replaced with local files?
update_drive <- FALSE

## ---------------------------------- ##
# Identify Drive Destinations ----
## ---------------------------------- ##

# Read in the inventory
invent_v01 <- readxl::read_excel(path = file.path("data", "data-inventory_raw.xlsx"), sheet = "rivers")

# Check structure
dplyr::glimpse(invent_v01)

# Generate subfolder names from networks (with special attention to networks with more than 500 rivers)
## (Drive has a 580 file-per-folder limit so we need to use more sub-folders in Drive than locally)
invent_v02 <- invent_v01 %>% 
  dplyr::filter(!is.na(network_site)) %>% 
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
    .fns = ~ tolower(gsub(pattern = " |_", replacement = "-", x = .)))) %>% 
  dplyr::mutate(std_filename = paste0(network_site, "_", country, "_", waterbody, "_", point_id, ".csv")) %>% 
  dplyr::select(unique.id, network_site, std_filename) %>% 
  dplyr::group_by(network_site) %>%
  dplyr::mutate(river_ct = length(unique(unique.id)),
    within.ntwk.id = seq_along(unique.id),
    within.ntwk.gp = ceiling(within.ntwk.id / 500),
    within.ntwk.gp = ifelse(nchar(within.ntwk.gp) > 1,
      yes = as.character(within.ntwk.gp), 
      no = paste0("0", within.ntwk.gp)),
    subfold = paste0(network_site, "_", within.ntwk.gp)) %>% 
  dplyr::ungroup()

# Check that out
dplyr::glimpse(invent_v02)
sort(unique(invent_v02$subfold))

## ---------------------------------- ##
# Export Standard Structure Files to Drive ----
## ---------------------------------- ##

# Identify local files
(local_std <- dir(path = file.path("data", "01-B_std-structure")))

# Identify link of Drive twin of this folder
drive_url <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/11Fmti4d0tIKLkXfcsNJXsbRTbaLZzXYy")

# Identify current sub-folders of that folder
(drive_subs <- googledrive::drive_ls(path = drive_url, type = "folder"))

# Gather contents of all of those subfolders
drive_files <- list()
for(focal_drive in sort(drive_subs$id)){
  drive_files[[as.character(focal_drive)]] <- googledrive::drive_ls(path = googledrive::as_id(focal_drive), 
    type = "csv")
}
drive_df <- purrr::list_rbind(x = drive_files)

# Check structure
dplyr::glimpse(drive_df)

# Iterate across standard files
for(focal_file in sort(local_std)){
  # focal_file <- "01-B_camrex-amazon_brazil_amazon_02.csv"

  # Skip alreadly-uploaded files (unless updating is desired)
  if(!focal_file %in% drive_df$name | update_drive == TRUE){

    # Grab the relevant bit of the subfolder dataframe
    focal_subfold <- invent_v02 %>% 
      dplyr::filter(std_filename == stringr::str_sub(string = focal_file, start = 6, end = nchar(focal_file)))

    # Create the sub-folder if it doesnt exist
    if(focal_subfold$subfold %in% drive_subs$name != TRUE){
      googledrive::drive_mkdir(name = focal_subfold$subfold,
        path = drive_url, overwrite = FALSE) 
    
      # And update the dribble of extant subfolders
      drive_subs <- googledrive::drive_ls(path = drive_url, type = "folder") 
    }

    # Get the Drive ID of that subfolder!
    focal_drive <- drive_subs %>% 
      dplyr::filter(name == focal_subfold$subfold)
    
    # Upload the relevant file to that folder
    googledrive::drive_upload(media = file.path("data", "01-B_std-structure", focal_file),
      path = focal_drive$id, overwrite = TRUE)

  } # Close conditional
} # Close loop

## ---------------------------------- ##
# Export Standard Contents Files to Drive ----
## ---------------------------------- ##

# TBD!

# End ----
